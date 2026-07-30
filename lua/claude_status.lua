-- claude_status.lua
-- Claude Code の statusLine スクリプト(~/.claude/statusline-command.sh)が
-- ~/.cache/claude-tasks/status/<cwd> に書くプレーンな status("dir (branch) ctx:%")を読み、
-- Claude端末ウィンドウの winbar(上部バー)に表示する。Claude 本体の下部フッターはそのまま。
--   * 端末が Claude かは b.claude_task(claude_tasks.lua が設定する dir)で判定。
--   * Claude端末を表示中のウィンドウだけ winbar を出す(他窓に空バーを出さない)。
--   * winbar は %{%...%} 式で毎 redraw 再評価 → ctx% がだいたいライブに更新される。
local M = {}
local STATUS_DIR = vim.fn.expand("~/.cache/claude-tasks/status")

-- claude-tasks 解決(絶対パスフォールバック。nvim-server 経由で PATH に無い場合に備える)
local ct_cmd = vim.fn.exepath("claude-tasks")
if ct_cmd == "" then
    local fb = vim.fn.expand("~/.claude_plugin/scripts/claude-tasks")
    ct_cmd = vim.fn.executable(fb) == 1 and fb or "claude-tasks"
end

-- この端末バッファのセッション sessionId を一度だけ非同期解決して b:claude_sid にキャッシュ。
-- (相関 pgrep が要るので render 内ではやらず、入室イベントで1回だけ。stable なので使い回す)
local function ensure_sid(buf)
    if vim.b[buf].claude_sid ~= nil then return end -- 解決済み or 進行中
    local dir = vim.b[buf].claude_task
    if not dir or dir == "" then return end
    vim.b[buf].claude_sid = "" -- 再キック防止マーカー
    vim.fn.jobstart({ ct_cmd, "sid", dir, vim.b[buf].claude_task_id or "" }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            local sid = ((data and data[1]) or ""):gsub("%s", "")
            if sid ~= "" and vim.api.nvim_buf_is_valid(buf) then
                vim.b[buf].claude_sid = sid
                pcall(vim.cmd, "redrawstatus")
            end
        end,
    })
end

-- claude_attention.norm と揃える(絶対パス・末尾スラッシュ無し)。statusLine 側のキーと一致させる。
local function norm(dir)
    if not dir or dir == "" then return "" end
    return (vim.fn.fnamemodify(dir, ":p"):gsub("/$", ""))
end

-- 現ウィンドウのバッファが Claude端末なら status 文字列、そうでなければ ""。
function M.text()
    local dir = vim.b.claude_task
    if not dir or dir == "" then return "" end
    local key = norm(dir):gsub("/", "%%") -- "/" → "%" (sed 's|/|%|g' と一致)
    local ok, lines = pcall(vim.fn.readfile, STATUS_DIR .. "/" .. key)
    if not ok or not lines or not lines[1] then return "" end
    return lines[1]
end

-- statusline に食わせるので "%" は "%%" にエスケープ。
local function esc(s) return (tostring(s or "")):gsub("%%", "%%%%") end

-- Claude の状態 → 先頭セグメントのラベルと色(ハイライトグループ名。テーマ追従)。
-- claude_attention と同じ kind。下バー(ui.lua の CA)と揃えてある。
local CA = {
    stop       = { label = "🔔 応答",    hl = "DiffAdd" },       -- あなたの番(緑系)
    ask        = { label = "❓ 選択待ち", hl = "Search" },        -- 質問/選択
    permission = { label = "🔒 許可待ち", hl = "DiffDelete" },    -- ブロック(赤系)
    idle       = { label = "💤 放置",    hl = "DiagnosticWarn" }, -- 橙系
    working    = { label = "⏳ 考え中",  hl = "Comment" },        -- 考え中(灰)
}

-- winbar 用。lualine のハイライトグループ(テーマ追従)で色付きセグメントにする。
-- 中身は statusLine スクリプトが "dir\tbranch\tctx" で書く(tab区切り)。Claude端末以外は ""。
-- 先頭セグメントは Claude の状態(考え中/待ち等)を表示し、状態に応じて色が変わる。
function M.winbar()
    local line = M.text()
    if line == "" then return "" end
    local dir, branch, ctx = line:match("^(.-)\t(.-)\t(.-)$")
    if not dir then dir, branch, ctx = line, "", "" end -- 旧フォーマット等のフォールバック

    -- 状態セグメント(claude_attention と同じソース)。状態が無ければ既定アクセント。
    local lead
    local ok, ca = pcall(require, "claude_attention")
    local st = (ok and ca.status_for) and ca.status_for(vim.b.claude_task) or nil
    local info = st and CA[st.kind] or nil
    if info then
        lead = "%#" .. info.hl .. "# " .. info.label .. " "
    else
        lead = "%#lualine_a_terminal# ✳ Claude "
    end

    local segs = {
        lead,
        "%#lualine_b_normal#  " .. esc(dir) .. " ",
    }
    -- path の後に session id(短縮)。同フォルダ複数(fork)でどのセッションか分かる。
    -- 解決前は slot(claude_task_id)で代用(fork なら "chat"/"2" 等、主は空)。
    local sid = vim.b.claude_sid
    if not sid or sid == "" then sid = vim.b.claude_task_id or "" end
    if sid ~= "" then
        segs[#segs + 1] = "%#lualine_c_normal# " .. esc(sid:sub(1, 8)) .. " "
    end
    if branch ~= "" then
        segs[#segs + 1] = "%#lualine_c_normal#  " .. esc(branch) .. " "
    end
    if ctx ~= "" then
        segs[#segs + 1] = "%#lualine_c_normal# ctx:" .. esc(ctx) .. " "
    end
    segs[#segs + 1] = "%#Normal#"
    return table.concat(segs)
end

function M.setup()
    local grp = vim.api.nvim_create_augroup("ClaudeStatusWinbar", { clear = true })
    -- TermEnter が肝: claude_tasks は 窓表示→jobstart→b.claude_task設定→startinsert の順なので、
    -- BufWinEnter/TermOpen 時点では b.claude_task が未設定。startinsert で入る TermEnter なら設定済み。
    vim.api.nvim_create_autocmd({ "TermEnter", "TermOpen", "BufWinEnter", "WinEnter", "BufEnter" }, {
        group = grp,
        callback = function()
            if vim.b.claude_task and vim.b.claude_task ~= "" then
                ensure_sid(vim.api.nvim_get_current_buf()) -- session id を一度だけ解決
                vim.wo.winbar = "%{%v:lua.require'claude_status'.winbar()%}"
            elseif type(vim.wo.winbar) == "string" and vim.wo.winbar:find("claude_status", 1, true) then
                vim.wo.winbar = "" -- 自分が付けた winbar だけ剥がす(他窓・他プラグインには触らない)
            end
        end,
    })
end

return M
