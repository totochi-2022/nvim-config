-- claude_board.lua
-- 複数プロジェクトの Claude セッションを俯瞰する常駐サイドペイン(:ClaudeBoard)。
--
-- 1 プロジェクト = 1〜2 行:
--   ●⌨ ~/.config/nvim   ⌨1 💤1
--      └ clipboard image…: 画面をコピーするか…
-- 並びは claude-tasks list と同じ(あなたの番 → 稼働中 → 考え中 → 停止)。
-- 停止中(○)でジョブも無い行は既定で畳む(a で全表示)。
--
-- データは claude-tasks に委譲(list = 稼働状態 / jobs = ~/.claude/jobs の待ち理由・結論)。
-- 2 本を非同期(jobstart)で取ってから描くので nvim は固まらない。表示中だけ 5 秒ごとに更新。
--
-- セッションを開いた時にボードも一緒に出すかは vim.g.claude_board_auto で選ぶ
-- (true = ボードあり / false・未設定 = 通常の claude だけ)。:ClaudeBoardAuto で切替。
-- トグルは window-local を避けてグローバル変数で持つ(CLAUDE.md の注意)。

local M = {}

local ct_cmd = vim.fn.exepath("claude-tasks")
if ct_cmd == "" then
  local fallback = vim.fn.expand("~/.claude_plugin/scripts/claude-tasks")
  ct_cmd = vim.fn.executable(fallback) == 1 and fallback or "claude-tasks"
end
local claude_cmd = vim.fn.exepath("claude")
if claude_cmd == "" then
  claude_cmd = "claude"
end

local BUFNAME = "claude://board"
local INTERVAL = 5000

local state = {
  buf = nil,
  timer = nil,
  busy = false,
  show_all = false,
  rows = {}, -- 描いた行番号 → { dir, id, jobs }
}

local function width()
  return vim.g.claude_board_width or 40
end

-- ===== データ取得 =====

-- 非同期でコマンドを実行し、stdout の行配列を cb に渡す
local function run(args, cb)
  local out = {}
  vim.fn.jobstart(args, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      out = data or {}
    end,
    on_exit = function()
      if out[#out] == "" then
        table.remove(out)
      end
      cb(out)
    end,
  })
end

-- claude-tasks jobs の TSV 列(claude-tasks の _jobs と対応)
local function parse_job(line)
  local f = vim.split(line, "\t", { plain = true })
  if #f < 5 then
    return nil
  end
  return {
    sid = f[1], glyph = f[2], state = f[3], updated = f[4], cwd = f[5],
    name = f[6] or "", intent = f[7] or "", needs = f[8] or "",
    suggested = f[9] or "", result = f[10] or "",
  }
end

-- list 行 + jobs 行 → 表示用の項目配列
local function build(list_lines, job_lines)
  local by_dir = {}
  for _, l in ipairs(job_lines) do
    local j = parse_job(l)
    if j and j.cwd ~= "" then
      by_dir[j.cwd] = by_dir[j.cwd] or {}
      table.insert(by_dir[j.cwd], j)
    end
  end
  for _, js in pairs(by_dir) do
    table.sort(js, function(a, b)
      return a.updated > b.updated
    end)
  end

  local items, seen = {}, {}
  local function add(mark, disp, dir, id)
    local js = by_dir[dir] or {}
    table.insert(items, { mark = mark, disp = disp, dir = dir, id = id or "", jobs = js })
    seen[dir] = true
  end
  for _, l in ipairs(list_lines) do
    local mark, disp, full, id = l:match("^(%S+)\t(.-)\t([^\t]+)\t?(.*)$")
    if full then
      -- 同フォルダの主+fork は別行で来る。ジョブ件数は最初の行にだけ付ける
      if seen[full] then
        table.insert(items, { mark = mark, disp = disp, dir = full, id = id or "", jobs = {} })
      else
        add(mark, disp, full, id)
      end
    end
  end
  -- 一覧(履歴)に無いフォルダのジョブも拾う
  for dir, _ in pairs(by_dir) do
    if not seen[dir] then
      add("○", vim.fn.fnamemodify(dir, ":~"), dir, "")
    end
  end
  return items
end

-- ===== 描画 =====

local function trunc(s, n)
  if vim.fn.strdisplaywidth(s) <= n then
    return s
  end
  return vim.fn.strcharpart(s, 0, math.max(1, n - 1)) .. "…"
end

-- 項目のひとこと: 入力待ち/待機の理由 → 完了の結論 → 作業中の依頼
local function headline(it)
  for _, want in ipairs({ "入力待ち", "待機", "完了", "作業中" }) do
    for _, j in ipairs(it.jobs) do
      if j.state == want then
        local why = (want == "完了") and j.result or (want == "作業中") and j.intent or j.needs
        if why == "" then
          why = j.intent
        end
        return j.glyph .. " " .. why
      end
    end
  end
  return nil
end

local function counts(it)
  local wait, idle = 0, 0
  for _, j in ipairs(it.jobs) do
    if j.state == "入力待ち" then
      wait = wait + 1
    elseif j.state == "待機" then
      idle = idle + 1
    end
  end
  local s = {}
  if wait > 0 then
    table.insert(s, "⌨" .. wait)
  end
  if idle > 0 then
    table.insert(s, "💤" .. idle)
  end
  return table.concat(s, " ")
end

local ns = vim.api.nvim_create_namespace("claude_board")

local function render(items)
  local buf = state.buf
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    return
  end
  local w = width() - 1
  local lines, rows, hl = {}, {}, {}
  local auto = vim.g.claude_board_auto and "ON" or "OFF"
  table.insert(lines, ("Claude Board  auto:%s  %s"):format(auto, os.date("%H:%M:%S")))
  table.insert(hl, { #lines, "Title" })
  table.insert(lines, "")
  local hidden = 0
  for _, it in ipairs(items) do
    local live = it.mark:find("●", 1, true) ~= nil
    if live or #it.jobs > 0 or state.show_all then
      local c = counts(it)
      local head = it.mark .. " " .. it.disp
      local room = w - vim.fn.strdisplaywidth(c) - 1
      head = trunc(head, room)
      local pad = math.max(1, w - vim.fn.strdisplaywidth(head) - vim.fn.strdisplaywidth(c))
      table.insert(lines, head .. (c ~= "" and (string.rep(" ", pad) .. c) or ""))
      rows[#lines] = it
      if not live then
        table.insert(hl, { #lines, "Comment" })
      end
      local h = headline(it)
      if h then
        table.insert(lines, trunc("   └ " .. h, w))
        rows[#lines] = it
        table.insert(hl, { #lines, "Comment" })
      end
    else
      hidden = hidden + 1
    end
  end
  if hidden > 0 then
    table.insert(lines, "")
    table.insert(lines, ("○ 停止中 %d 件（a で表示）"):format(hidden))
    table.insert(hl, { #lines, "Comment" })
  end
  table.insert(lines, "")
  table.insert(lines, "⏎開く s:id一覧 x:片付け a:全表示 r:更新 q:閉じる")
  table.insert(hl, { #lines, "Comment" })

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, h in ipairs(hl) do
    vim.api.nvim_buf_set_extmark(buf, ns, h[1] - 1, 0, { line_hl_group = h[2] })
  end
  state.rows = rows
  state.items = items
end

-- ===== ウィンドウ =====

local function board_win()
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    return nil
  end
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(w) == state.buf then
      return w
    end
  end
  return nil
end

function M.refresh()
  if state.busy or not board_win() then
    return
  end
  state.busy = true
  local list, jobs
  local function done()
    if list and jobs then
      state.busy = false
      render(build(list, jobs))
    end
  end
  run({ ct_cmd, "list" }, function(out)
    list = out
    done()
  end)
  run({ ct_cmd, "jobs" }, function(out)
    jobs = out
    done()
  end)
end

local function start_timer()
  if state.timer then
    return
  end
  state.timer = vim.uv.new_timer()
  state.timer:start(INTERVAL, INTERVAL, vim.schedule_wrap(function()
    if not board_win() then
      state.timer:stop()
      state.timer:close()
      state.timer = nil
      return
    end
    M.refresh()
  end))
end

-- ボード以外のウィンドウ(セッションを開く先)。直前のウィンドウ優先、無ければ左に作る。
local function target_win()
  local bw = board_win()
  local prev = vim.fn.win_getid(vim.fn.winnr("#"))
  if prev ~= 0 and prev ~= bw and vim.api.nvim_win_is_valid(prev) then
    return prev
  end
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if w ~= bw and vim.api.nvim_win_get_config(w).relative == "" then
      return w
    end
  end
  vim.cmd("leftabove vnew")
  return vim.api.nvim_get_current_win()
end

local function item_at_cursor()
  return state.rows[vim.api.nvim_win_get_cursor(0)[1]]
end

-- x: そのフォルダのジョブを claude rm で片付ける(作業中は対象外=消すと困る)
local function cleanup(it)
  local cands = {}
  for _, j in ipairs(it.jobs) do
    if j.state ~= "作業中" then
      table.insert(cands, j)
    end
  end
  if #cands == 0 then
    vim.notify("片付けられるジョブはありません（作業中は対象外）", vim.log.levels.INFO)
    return
  end
  local choices = { { label = ("全部（%d 件）"):format(#cands), jobs = cands } }
  for _, j in ipairs(cands) do
    table.insert(choices, {
      label = ("%s %s  %s"):format(j.glyph, j.sid:sub(1, 8), j.name),
      jobs = { j },
    })
  end
  vim.ui.select(choices, {
    prompt = "claude rm で消すジョブ（" .. vim.fn.fnamemodify(it.dir, ":~") .. "）",
    format_item = function(c)
      return c.label
    end,
  }, function(c)
    if not c then
      return
    end
    for _, j in ipairs(c.jobs) do
      local short = j.sid:sub(1, 8)
      run({ claude_cmd, "rm", short }, function(out)
        local msg = table.concat(out, " ")
        vim.notify(("claude rm %s: %s"):format(short, msg ~= "" and msg or "done"))
        M.refresh()
      end)
    end
  end)
end

local function setup_buf(buf)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "claudeboard"
  vim.bo[buf].modifiable = false
  local function map(lhs, fn, desc)
    vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true, desc = desc })
  end
  map("<CR>", function()
    local it = item_at_cursor()
    if not it then
      return
    end
    vim.api.nvim_set_current_win(target_win())
    require("claude_tasks").open(it.dir, { id = it.id })
  end, "セッションを開く")
  map("s", function()
    local it = item_at_cursor()
    if not it then
      return
    end
    -- pick_sessions は現ウィンドウに開くので、先にボード外へ移る
    vim.api.nvim_set_current_win(target_win())
    require("claude_tasks").pick_sessions(it.dir)
  end, "id 一覧から選ぶ")
  map("x", function()
    local it = item_at_cursor()
    if it then
      cleanup(it)
    end
  end, "ジョブを片付ける(claude rm)")
  map("a", function()
    state.show_all = not state.show_all
    if state.items then
      render(state.items)
    end
  end, "停止中も表示")
  map("r", M.refresh, "更新")
  map("q", M.close, "閉じる")
end

-- ボードを開く。opts.focus=false なら開いた後に元のウィンドウへ戻る。
function M.open(opts)
  opts = opts or {}
  local cur = vim.api.nvim_get_current_win()
  local w = board_win()
  if not w then
    if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
      state.buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(state.buf, BUFNAME)
      setup_buf(state.buf)
    end
    local side = (vim.g.claude_board_side == "left") and "topleft" or "botright"
    vim.cmd(side .. " vertical " .. width() .. "split")
    w = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(w, state.buf)
    vim.wo[w].winfixwidth = true
    vim.wo[w].number = false
    vim.wo[w].relativenumber = false
    vim.wo[w].signcolumn = "no"
    vim.wo[w].wrap = false
    vim.wo[w].cursorline = true
    if not state.items then
      render({})
    end
  end
  start_timer()
  M.refresh()
  if opts.focus == false then
    vim.api.nvim_set_current_win(cur)
  else
    vim.api.nvim_set_current_win(w)
  end
end

function M.close()
  local w = board_win()
  if w and #vim.api.nvim_tabpage_list_wins(0) > 1 then
    vim.api.nvim_win_close(w, false)
  end
end

function M.toggle()
  if board_win() then
    M.close()
  else
    M.open()
  end
end

-- claude_tasks がセッションを開いた直後に呼ぶ。auto が ON ならフォーカスを奪わずにボードを出す。
function M.auto()
  if vim.g.claude_board_auto and not board_win() then
    M.open({ focus = false })
  end
end

function M.setup()
  vim.api.nvim_create_user_command("ClaudeBoard", function()
    M.toggle()
  end, { desc = "Claude セッションの俯瞰ボード(右ペイン)を開閉" })
  vim.api.nvim_create_user_command("ClaudeBoardAuto", function(o)
    if o.args == "on" then
      vim.g.claude_board_auto = true
    elseif o.args == "off" then
      vim.g.claude_board_auto = false
    else
      vim.g.claude_board_auto = not vim.g.claude_board_auto
    end
    vim.notify("Claude を開く時にボードも出す: " .. (vim.g.claude_board_auto and "ON" or "OFF"))
    if state.items then
      render(state.items)
    end
  end, {
    nargs = "?",
    complete = function()
      return { "on", "off" }
    end,
    desc = "セッションを開く時にボードも出すか(引数なし=切替)",
  })
end

return M
