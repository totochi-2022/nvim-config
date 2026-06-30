-- z_jump.lua
-- fish の z プラグイン(jethrokuan/z)が貯める frecency 履歴を Telescope で開き、
-- 選択したディレクトリへ :cd する。履歴は read-only で参照（書き戻しはしない）。
--   データ形式: 1行 = "path|rank|time"（| 区切り）
--   場所:        $Z_DATA（既定 ~/.local/share/z/data）

local M = {}

-- fish 側 conf.d/z.fish と同じ既定パス。env を上書きしていれば $Z_DATA を尊重。
local DATA = vim.env.Z_DATA or vim.fn.expand('~/.local/share/z/data')

-- z / autojump 系の frecency 計算（最終訪問からの経過で rank を重み付け）
local function frecency(rank, last)
    local dt = os.time() - last
    if dt < 3600 then
        return rank * 4
    elseif dt < 86400 then
        return rank * 2
    elseif dt < 604800 then
        return rank * 0.5
    else
        return rank * 0.25
    end
end

local function load_entries()
    local entries = {}
    local f = io.open(DATA, 'r')
    if not f then
        return entries
    end
    for line in f:lines() do
        -- path にはまず "|" は含まれない前提（z 側も | 区切りで保存）
        local path, rank, time = line:match('^(.*)|([%d%.]+)|(%d+)$')
        if path and path ~= '' then
            entries[#entries + 1] = {
                path = path,
                score = frecency(tonumber(rank) or 0, tonumber(time) or 0),
            }
        end
    end
    f:close()
    table.sort(entries, function(a, b)
        return a.score > b.score
    end)
    return entries
end

-- Telescope ピッカーを開く。<CR> で global :cd。
function M.pick(opts)
    opts = opts or {}
    if not pcall(require, 'telescope') then
        vim.notify('z_jump: telescope.nvim が必要です', vim.log.levels.ERROR)
        return
    end
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local previewers = require('telescope.previewers')

    local results = load_entries()
    if #results == 0 then
        vim.notify('z_jump: 履歴が空です (' .. DATA .. ')', vim.log.levels.WARN)
        return
    end

    -- 選択中ディレクトリの中身を eza で表示
    local previewer = previewers.new_termopen_previewer({
        get_command = function(entry)
            local p = entry.value
            if vim.fn.isdirectory(p) ~= 1 then
                return { 'echo', '(存在しません) ' .. p }
            end
            return { 'eza', '-la', '--group-directories-first', '--icons', '--color=always', p }
        end,
    })

    pickers.new(opts, {
        prompt_title = 'z jump (frecency)',
        finder = finders.new_table({
            results = results,
            entry_maker = function(e)
                return {
                    value = e.path,
                    display = vim.fn.fnamemodify(e.path, ':~'), -- ~ 短縮で表示
                    ordinal = e.path,
                    path = e.path,
                }
            end,
        }),
        sorter = conf.generic_sorter(opts),
        previewer = previewer,
        attach_mappings = function(prompt_bufnr, _map)
            actions.select_default:replace(function()
                local entry = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if not (entry and entry.value) then
                    return
                end
                if vim.fn.isdirectory(entry.value) ~= 1 then
                    vim.notify('z_jump: ディレクトリが存在しません: ' .. entry.value, vim.log.levels.WARN)
                    return
                end
                vim.cmd('cd ' .. vim.fn.fnameescape(entry.value))
                vim.notify('cd: ' .. vim.fn.fnamemodify(entry.value, ':~'))
            end)
            return true
        end,
    }):find()
end

return M
