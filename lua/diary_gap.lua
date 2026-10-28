-- diary_gap.lua — 1 日の振り返り(diary-gap が毎朝 6 時に作るレポート)を見る。
-- 実体は claude-plugin-system の `diary-gap`(~/.claude_plugin/scripts)。レポートは ~/.local/share/diary-gap/。
-- 見るだけなら Claude は起こさない: サマリーの節と未処理の件数を nvim のバッファに出す。
-- 日記にする(候補を選ぶ)時だけ、そのバッファの c で日記フォルダの Claude を開いて /diary-gap。
-- 起動画面(dashboard)の d と :DiaryGap から呼ぶ。
local M = {}

local DIARY_DIR = vim.fn.expand("~/.config/nvim/data/howm")

-- 最新レポート → { lines, n = 未処理の件数, conflicts = 食い違いの件数, day = "MM-DD" }。無ければ nil
-- 未処理 = 「日記にした方がいい項目」の見出し(### N.)のうち ✅ 日記済み / ⏭ 見送り の印が無いもの
function M.state()
  local path = vim.fn.systemlist({ "diary-gap", "--latest" })[1]
  if vim.v.shell_error ~= 0 or not path then
    return nil
  end
  local lines = vim.fn.readfile(path)
  local n, conflicts, sec = 0, 0, ""
  for _, l in ipairs(lines) do
    if l:match("^## ") then
      sec = l
    elseif l:match("^### %d+%.") and not l:find("✅", 1, true) and not l:find("⏭", 1, true) then
      n = n + 1
    elseif sec == "## 日記と食い違っているもの" and l:match("^%- ") then
      conflicts = conflicts + 1
    end
  end
  local name = vim.fn.fnamemodify(path, ":t:r")
  return { path = path, lines = lines, n = n, conflicts = conflicts, date = name:sub(1, 10), day = name:sub(6, 10) }
end

-- 起動画面の項目名
function M.label()
  local g = M.state()
  if not g then
    return "󰃭 振り返り"
  end
  return g.n > 0 and ("󰃭 振り返り %d件 (%s)"):format(g.n, g.day) or ("󰃭 振り返り 済 (%s)"):format(g.day)
end

-- 収集(diary-gap)をこの場で始める。毎朝 6 時のタイマーが動かなかった時の保険(d / :DiaryGap で今日の分が無い時)。
-- 数分かかるので裏で走らせ、始めた時と終わった時に知らせる。二重に走っても diary-gap 側のロックで 1 つだけ動く
local running = false
function M.collect()
  if running then
    vim.notify("振り返りを収集中です(終わったら知らせます)", vim.log.levels.INFO)
    return
  end
  running = true
  vim.notify("振り返りの収集を始めました(数分かかります。終わったら知らせます)", vim.log.levels.INFO)
  vim.fn.jobstart({ "diary-gap" }, {
    on_exit = function(_, code)
      running = false
      vim.schedule(function()
        if code == 0 then
          vim.notify("振り返りができました(起動画面の d か :DiaryGap で見る)", vim.log.levels.INFO)
        else
          vim.notify(("振り返りの収集に失敗しました(終了コード %d)"):format(code), vim.log.levels.WARN)
        end
      end)
    end,
  })
end

-- 収集が必要か: 今日の 6 時(タイマーの時刻)を過ぎていて、最新のレポートがそれより前(前日以前)に作られたもの。
-- 6 時より前は、前日のレポートしか無いのが普通なので収集しない(すぐ後にタイマーが走る)
local RUN_HOUR = 6
function M.due(g)
  local t = os.date("*t")
  t.hour, t.min, t.sec = RUN_HOUR, 0, 0
  local run_at = os.time(t)
  if os.time() < run_at then
    return false
  end
  if not g then
    return true
  end
  -- 作った時刻はファイル名(YYYY-MM-DD-HHMM)で見る。更新時刻は ✅/⏭ の印を付けると変わるので使わない
  local y, mo, d, h, mi = vim.fn.fnamemodify(g.path, ":t:r"):match("^(%d+)-(%d+)-(%d+)-(%d%d)(%d%d)")
  if not y then
    return true
  end
  return os.time({ year = y, month = mo, day = d, hour = h, min = mi, sec = 0 }) < run_at
end

-- 日記にする: 日記フォルダで Claude を開いて /diary-gap(候補の一覧・日記化・印付けは Claude 側)
function M.claude()
  require("claude_tasks").open_prompt(DIARY_DIR, "/diary-gap")
end

-- 表示用の行に組み直す: タイトル → サマリー(プロジェクトごとに見出し＋本文) → 日記にした方がいい項目のチェックリスト
-- (✅ 日記済み = [x]、⏭ 見送り = 打ち消し線、未処理 = [ ]) → 食い違いの件数 → キーの説明
-- 動いたまま(止めていない)のセッション: claude-tasks list のうち停止中(off)以外。
-- 列: mark / 表示名 / dir / id / 状態 / 最終利用(epoch)。最後に会話した時刻の古い順(開きっぱなしが上)
local ct = vim.fn.exepath("claude-tasks")
if ct == "" then ct = vim.fn.expand("~/.claude_plugin/scripts/claude-tasks") end

local function live_sessions()
  local rows = {}
  for _, line in ipairs(vim.fn.systemlist({ ct, "list" })) do
    local f = vim.split(line, "\t", { plain = true })
    if f[5] and f[5] ~= "off" and f[5] ~= "" then
      rows[#rows + 1] = { mark = f[1], disp = f[2], dir = f[3], id = f[4] or "", at = tonumber(f[6] or "") or 0 }
    end
  end
  table.sort(rows, function(a, b) return a.at < b.at end)
  return rows
end

-- 返り値: 表示する行, 動いたままのセッションの {行番号 = セッション}(x で止める対象)
local function view_lines(g)
  local out, sec, live_at = {}, "", {}
  for _, l in ipairs(g.lines) do
    if l:match("^# ") then
      out[#out + 1] = l
    elseif l:match("^## ") then
      sec = l
      if sec == "## サマリー" then
        vim.list_extend(out, { "", "## サマリー" })
      elseif sec == "## 日記にした方がいい項目" then
        vim.list_extend(out, { "", ("## 日記にした方がいい項目（未処理 %d 件）"):format(g.n), "" })
      end
    elseif sec == "## サマリー" then
      -- "- **プロジェクト**: 本文" → 見出しと本文に分ける
      local proj, body = l:match("^%- %*%*(.-)%*%*[:：]%s*(.*)$")
      if proj then
        vim.list_extend(out, { "", "### " .. proj, body })
      elseif l:match("%S") then
        out[#out + 1] = l
      end
    elseif sec == "## 日記にした方がいい項目" then
      local num, title = l:match("^### (%d+)%. (.*)$")
      if num then
        if title:find("✅", 1, true) then
          out[#out + 1] = ("- [x] %s. %s"):format(num, title)
        elseif title:find("⏭", 1, true) then
          out[#out + 1] = ("- ~~%s. %s~~"):format(num, title)
        else
          out[#out + 1] = ("- [ ] %s. %s"):format(num, title)
        end
      end
    end
  end
  local live = live_sessions()
  if #live > 0 then
    vim.list_extend(out, { "", ("## 動いたままのセッション（%d）"):format(#live), "" })
    for _, r in ipairs(live) do
      out[#out + 1] = ("- %s %s　最後の会話 %s"):format(r.mark, r.disp, r.at > 0 and os.date("%m/%d %H:%M", r.at) or "?")
      live_at[#out] = r
    end
  end
  if g.conflicts > 0 then
    vim.list_extend(out, { "", ("> 日記と食い違っているもの: %d 件（c で Claude に聞く）"):format(g.conflicts) })
  end
  return out, live_at
end

-- サマリーを浮動ウィンドウで見る(Claude は起こさない)。c で Claude、q / Esc で閉じる
function M.open()
  local g = M.state()
  -- 今日 6 時以降のレポートがまだ無ければ収集を始める(前のレポートがあればそれは表示する)
  if M.due(g) then
    M.collect()
  end
  if not g then
    return
  end
  -- 見た印。次の収集で、見ていないサマリーだけを今回分と合わせてまとめ直すのに使う
  pcall(function() io.open(g.path .. ".seen", "w"):close() end)
  local buf = vim.api.nvim_create_buf(false, true)
  local live_at = {}
  local function render()
    local lines
    lines, live_at = view_lines(g)
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
  end
  render()
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].bufhidden = "wipe"
  local cols, rows = vim.o.columns, vim.o.lines
  local width = math.min(100, cols - 6)
  local height = math.min(rows - 6, 40)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", style = "minimal", border = "rounded",
    width = width, height = height,
    row = math.floor((rows - height) / 2) - 1, col = math.floor((cols - width) / 2),
    title = (" 振り返り %s "):format(g.day), title_pos = "center",
    footer = " c: Claude で日記にする   x: カーソル行のセッションを止める   q: 閉じる ", footer_pos = "center",
  })
  -- 長い 1 行を窓の幅で折り返し、2 行目以降も字下げをそろえる
  vim.wo[win].wrap, vim.wo[win].linebreak, vim.wo[win].breakindent = true, true, true
  vim.wo[win].conceallevel = 2
  -- render-markdown は普段オフ(トグルで切替)。この窓だけ描画する
  pcall(function() require("render-markdown").buf_enable() end)
  local function close() pcall(vim.api.nvim_win_close, win, true) end
  vim.keymap.set("n", "q", close, { buffer = buf, desc = "振り返り: 閉じる" })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, desc = "振り返り: 閉じる" })
  vim.keymap.set("n", "c", function() close(); M.claude() end, { buffer = buf, desc = "振り返り: Claude で日記にする" })
  -- x: 「動いたままのセッション」の行のセッションを止める(claude-tasks exit = SIGTERM。止めた後に取り込みも)。
  -- 止まったら一覧を描き直す
  vim.keymap.set("n", "x", function()
    local r = live_at[vim.api.nvim_win_get_cursor(win)[1]]
    if not r then
      vim.notify("「動いたままのセッション」の行で x を押すと止めます", vim.log.levels.INFO)
      return
    end
    vim.notify(("止めています: %s"):format(r.disp))
    vim.fn.jobstart({ ct, "exit", r.dir, r.id }, {
      on_exit = function()
        vim.schedule(function()
          vim.notify(("止めました: %s"):format(r.disp))
          if vim.api.nvim_buf_is_valid(buf) then render() end
        end)
      end,
    })
  end, { buffer = buf, desc = "振り返り: カーソル行のセッションを止める" })
end

vim.api.nvim_create_user_command("DiaryGap", M.open, { desc = "1 日の振り返り(サマリー)を見る" })

return M
