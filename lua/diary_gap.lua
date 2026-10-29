-- diary_gap.lua — 1 日の振り返り(diary-gap が毎朝 6 時に作るレポート)を見る。
-- 実体は claude-plugin-system の `diary-gap`(~/.claude_plugin/scripts)。レポートは ~/.local/share/diary-gap/。
-- 見るだけなら Claude は起こさない: サマリーの節と未処理の件数を nvim のバッファに出す。
-- 日記にする(候補を選ぶ)時だけ、そのバッファの c で日記フォルダの Claude を開いて /diary-gap。
-- 起動画面(dashboard)の d と :DiaryGap から呼ぶ。
local M = {}

local DIARY_DIR = vim.fn.expand("~/.config/nvim/data/howm")

local CONFLICTS = "## 日記と食い違っているもの"

-- 印は行の末尾に足す。誰が付けたかで分ける(2 回目に見た時、頼んだだけか Claude が済ませたかが分かるように):
--   あなた(この画面の <Space>): 📝 日記に(候補を日記にして) / ⏭ 見送り / 🗑 戻して(⚠ を外して)
--   Claude(/diary-gap):         ✅ 日記済み [[日記]] / ⏭ 見送り / ⏭ 戻した
-- 「日記と食い違っているもの」は付け済みの ⚠ の一覧なので、印が無ければ「そのまま」(数えない)
local function has(l, m) return l:find(" " .. m, 1, true) ~= nil end

-- 済んだか(Claude を待つものが無い)
local function done(l)
  return has(l, "✅") or has(l, "⏭")
end

-- 印を外した本文(印から行末まで落とす)。印は複数バイトなので文字クラスにせず 1 つずつ
local function unmarked(l)
  for _, m in ipairs({ "✅", "⏭", "📝", "🗑" }) do
    l = l:gsub(" " .. m .. ".*$", "")
  end
  return l
end

-- 最新レポート → { lines, n = 未処理の候補の数, conflicts = 戻す待ちの ⚠ の数, day = "MM-DD" }。無ければ nil
-- 未処理の候補 = 「日記にした方がいい項目」の見出し(### N.)のうち ✅ / ⏭ の無いもの(📝 は Claude 待ちなので数える)
-- 戻す待ち = 「日記と食い違っているもの」の行(- …)のうち 🗑 が付いて、まだ ⏭ 戻した になっていないもの
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
    elseif l:match("^### %d+%.") and not done(l) then
      n = n + 1
    elseif sec == CONFLICTS and l:match("^%- ") and has(l, "🗑") and not done(l) then
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
  local n = g.n + g.conflicts
  return n > 0 and ("󰃭 振り返り %d件 (%s)"):format(n, g.day) or ("󰃭 振り返り 済 (%s)"):format(g.day)
end

-- 収集(diary-gap)をこの場で始める。毎朝 6 時のタイマーが動かなかった時の保険(d / :DiaryGap で今日の分が無い時)。
-- 数分かかるので裏で走らせ、始めた時と終わった時に知らせる。on_done は終わった時に呼ぶ(開いている画面の切り替え)。
-- --wait: 起動直後などでタイマーの収集がすでに走っていたら、それが終わるのを待つ(二重には作らず、早すぎる「できました」も出さない)
local running, waiting = false, {}
function M.collect(on_done)
  if on_done then waiting[#waiting + 1] = on_done end
  if running then
    vim.notify("振り返りを収集中です(終わったら知らせます)", vim.log.levels.INFO)
    return
  end
  running = true
  vim.notify("振り返りの収集を始めました(数分かかります。終わったら画面を切り替えます)", vim.log.levels.INFO)
  vim.fn.jobstart({ "diary-gap", "--wait" }, {
    on_exit = function(_, code)
      running = false
      vim.schedule(function()
        if code == 0 then
          vim.notify("振り返りができました", vim.log.levels.INFO)
        else
          vim.notify(("振り返りの収集に失敗しました(終了コード %d)"):format(code), vim.log.levels.WARN)
        end
        local cbs = waiting
        waiting = {}
        for _, cb in ipairs(cbs) do pcall(cb, code == 0) end
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

-- 表示用の行に組み直す: タイトル → サマリー(プロジェクトごとに見出し＋本文) → 日記にした方がいい項目と
-- 日記と食い違っているもの(付け済みの ⚠)の一覧。印は下の check_line / conflict_line で表示に置き換える
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

-- 候補の 1 行: 未処理 [ ] / 📝 頼んだ(Claude 待ち) / ✅ Claude が日記にした [x] → [[日記]] / ⏭ 見送り
-- (打ち消し線 ~~…~~ は本文のパスの ~ と混ざって崩れるので使わない)
local function check_line(text, l)
  local body = unmarked(text)
  if has(l, "✅") then
    local link = l:match(" ✅.-(%[%[.-%]%])")
    return ("- [x] %s%s"):format(body, link and (" → " .. link) or "")
  elseif has(l, "⏭") then
    return ("- ⏭ %s　（見送り）"):format(body)
  elseif has(l, "📝") then
    return ("- 📝 %s　（日記に頼んだ・Claude 待ち）"):format(body)
  end
  return ("- [ ] %s"):format(body)
end

-- ⚠ の 1 行: そのまま ⚠ / 🗑 戻して(Claude 待ち) / ⏭ Claude が戻した
local function conflict_line(text, l)
  local body = unmarked(text)
  if has(l, "⏭") then
    return ("- ⏭ %s　（戻した）"):format(body)
  elseif has(l, "🗑") then
    return ("- 🗑 %s　（戻して・Claude 待ち）"):format(body)
  end
  return ("- ⚠ %s"):format(body)
end

-- 返り値: 表示する行, 動いたままのセッションの {行番号 = セッション}(x で止める対象),
-- チェックリストの {表示の行番号 = レポートの行番号}(<Space> で印を付ける対象)
local function view_lines(g)
  local out, sec, live_at, item_at = {}, "", {}, {}
  if not g then  -- レポートがまだ 1 本も無い(収集中)
    out = { "# 振り返り（収集中…）", "", "できたらこの画面に出します（数分）。" }
  end
  for i, l in ipairs(g and g.lines or {}) do
    if l:match("^# ") then
      out[#out + 1] = l
    elseif l:match("^## ") then
      sec = l
      if sec == "## サマリー" then
        vim.list_extend(out, { "", "## サマリー" })
      elseif sec == "## 日記にした方がいい項目" then
        vim.list_extend(out, { "", ("## 日記にした方がいい項目（未処理 %d 件）"):format(g.n), "" })
      elseif sec == CONFLICTS then
        vim.list_extend(out, { "", ("## 日記に付けた ⚠（戻す待ち %d 件。印が無ければそのまま）"):format(g.conflicts), "" })
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
      local text = l:match("^### (%d+%. .*)$")
      if text then
        out[#out + 1] = check_line(text, l)
        item_at[#out] = i
      end
    elseif sec == CONFLICTS and l:match("^%- ") then
      out[#out + 1] = conflict_line(l:sub(3), l)
      item_at[#out] = i
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
  return out, live_at, item_at
end

-- レポートの i 行目の印を回す(あなたの印だけ。Claude が済ませた行は触らない → false):
--   候補: 未処理 → 📝 日記に → ⏭ 見送り → 未処理 / ⚠: そのまま ⇄ 🗑 戻して
local function cycle_mark(g, i)
  local l = g.lines[i]
  local base = unmarked(l)
  if l:match("^### ") then
    if has(l, "✅") then return false end
    l = has(l, "📝") and (base .. " ⏭ 見送り") or has(l, "⏭") and base or (base .. " 📝 日記に")
  else
    if has(l, "⏭") then return false end
    l = has(l, "🗑") and base or (base .. " 🗑 戻して")
  end
  g.lines[i] = l
  vim.fn.writefile(g.lines, g.path)
  return true
end

-- 印とキーのヘルプ(振り返りの画面の上に重ねる。? / h で開き、q / Esc / ? / h で閉じる)
local HELP = {
  "# 振り返りのヘルプ",
  "",
  "## 日記にした方がいい項目",
  "",
  "| 表示 | 意味 | 付けるのは |",
  "|---|---|---|",
  "| [ ] | 未処理（件数に入る） | — |",
  "| 📝 …（Claude 待ち） | 日記にしてほしい（件数に入る） | あなた（<Space>） |",
  "| ⏭ …（見送り） | 日記にしない | あなた（<Space>） |",
  "| [x] … → [[日記]] | 日記にした。もう変えられない | Claude だけ |",
  "",
  "<Space>: 未処理 → 📝 → ⏭ → 未処理（[x] の行は変わらない）",
  "",
  "## 日記に付けた ⚠",
  "",
  "その期間に日記に付いた ⚠（注意ラベル）の一覧。どれも付け済み。",
  "",
  "| 表示 | 意味 | 付けるのは |",
  "|---|---|---|",
  "| ⚠ … | そのまま残す（印なし。何もしなくてよい） | — |",
  "| 🗑 …（Claude 待ち） | 外してほしい（件数に入る） | あなた（<Space>） |",
  "| ⏭ …（戻した） | 日記から外した。もう変えられない | Claude だけ |",
  "",
  "<Space>: ⚠ ⇄ 🗑（⏭ の行は変わらない）",
  "",
  "## いつまで変えられるか",
  "",
  "- 変えられるのは、このレポートが出ている間（次の朝に新しいレポートができるまで）。",
  "- d を 1 回も開かなかった日は、前のレポートと結合される（⚠ も集め直す）。",
  "- 📝 / 🗑 を付けたまま朝になったものは、次のレポートに引き継ぐ。",
  "- それより後に変えたい時は、Claude に頼む（日記の方も一緒に直す）。",
  "",
  "## キー",
  "",
  "- c: Claude を呼ぶ（📝 / 🗑 があれば聞き返さずに片付ける。無ければ一覧から選ぶ）",
  "- <Space>: 印を切り替える",
  "- x: 「動いたままのセッション」の行のセッションを止める",
  "- ? / h: このヘルプ　　q / Esc: 閉じる",
}

local function show_help()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, HELP)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].bufhidden = "wipe"
  local width = math.min(vim.o.columns - 8, 90)
  local height = math.min(vim.o.lines - 8, #HELP + 2)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", style = "minimal", border = "rounded", zindex = 60,
    width = width, height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1, col = math.floor((vim.o.columns - width) / 2),
    title = " 振り返りのヘルプ ", title_pos = "center",
    footer = " q / Esc / ? / h: 閉じる ", footer_pos = "center",
  })
  vim.wo[win].wrap, vim.wo[win].linebreak, vim.wo[win].conceallevel = true, true, 2
  pcall(function() require("render-markdown").buf_enable() end)
  for _, k in ipairs({ "q", "<Esc>", "?", "h" }) do
    vim.keymap.set("n", k, function() pcall(vim.api.nvim_win_close, win, true) end, { buffer = buf, nowait = true })
  end
end

-- サマリーを浮動ウィンドウで見る(Claude は起こさない)。c で Claude、q / Esc で閉じる
function M.open()
  local g = M.state()
  -- 今日 6 時以降のレポートがまだ無ければ収集を始める。画面は前のレポート(無ければ「収集中…」)で開き、
  -- 収集が終わったら今日のレポートに切り替える
  local collecting = M.due(g)
  local function mark_seen()
    -- 見た印。次の収集で、見ていないサマリーだけを今回分と合わせてまとめ直すのに使う。
    -- 収集中に前のレポートを出しているだけの時は付けない(ちゃんと見たとは限らない)
    if g and not collecting then pcall(function() io.open(g.path .. ".seen", "w"):close() end) end
  end
  mark_seen()
  local buf = vim.api.nvim_create_buf(false, true)
  local live_at, item_at = {}, {}
  local function render()
    local lines
    lines, live_at, item_at = view_lines(g)
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
  end
  render()
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].bufhidden = "wipe"
  local cols, rows = vim.o.columns, vim.o.lines
  -- 内容が多いので画面いっぱいに開く(起動画面は隠れてよい)。枠の分と、下のコマンド行の分だけ空ける
  local width = cols - 4
  local height = rows - 5
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", style = "minimal", border = "rounded",
    width = width, height = height,
    row = math.floor((rows - height) / 2) - 1, col = math.floor((cols - width) / 2),
    title = "", title_pos = "center",
    footer = " c: Claude で日記にする   <Space>: 日記に/見送り（⚠ は戻して）   x: セッションを止める   ?: ヘルプ   q: 閉じる ", footer_pos = "center",
  })
  local function set_title()
    local t = g and (" 振り返り %s "):format(g.day) or " 振り返り "
    if collecting then t = t .. "（今日の分を収集中…） " end
    pcall(vim.api.nvim_win_set_config, win, { title = t, title_pos = "center" })
  end
  set_title()
  if collecting then
    M.collect(function()
      collecting = false
      if not vim.api.nvim_win_is_valid(win) then return end
      g = M.state()
      render()
      set_title()
      mark_seen()
    end)
  end
  -- 長い 1 行を窓の幅で折り返し、2 行目以降も字下げをそろえる
  vim.wo[win].wrap, vim.wo[win].linebreak, vim.wo[win].breakindent = true, true, true
  vim.wo[win].conceallevel = 2
  -- render-markdown は普段オフ(トグルで切替)。この窓だけ描画する
  pcall(function() require("render-markdown").buf_enable() end)
  local function close() pcall(vim.api.nvim_win_close, win, true) end
  vim.keymap.set("n", "q", close, { buffer = buf, desc = "振り返り: 閉じる" })
  vim.keymap.set("n", "?", show_help, { buffer = buf, nowait = true, desc = "振り返り: ヘルプ" })
  vim.keymap.set("n", "h", show_help, { buffer = buf, nowait = true, desc = "振り返り: ヘルプ" })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, desc = "振り返り: 閉じる" })
  vim.keymap.set("n", "c", function() close(); M.claude() end, { buffer = buf, desc = "振り返り: Claude で日記にする" })
  -- <Space>: チェックリストの行の印を回す(cycle_mark)。レポートに書いて描き直す。c で Claude を呼ぶと 📝 / 🗑 を片付ける
  vim.keymap.set("n", "<Space>", function()
    local i = item_at[vim.api.nvim_win_get_cursor(win)[1]]
    if not (g and i) then
      vim.notify("候補の行で <Space>: 日記に → 見送り → 未処理。⚠ の行で <Space>: 戻して ⇄ そのまま", vim.log.levels.INFO)
      return
    end
    if not cycle_mark(g, i) then
      vim.notify("Claude が済ませた行です（印は変えません）", vim.log.levels.INFO)
      return
    end
    g = M.state()
    local cur = vim.api.nvim_win_get_cursor(win)
    render()
    pcall(vim.api.nvim_win_set_cursor, win, cur)
  end, { buffer = buf, nowait = true, desc = "振り返り: 日記に/見送り/戻して を切り替える" })
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
