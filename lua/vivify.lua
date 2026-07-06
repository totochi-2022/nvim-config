-- vivify.lua — ,,V のデュアルモード起動
--   web(nvim-server)接続中 → 右プレビューペイン(iframe)に Vivify を表示
--   端末/Neovide      → 従来どおりブラウザタブ(vivify.vim の :Vivify)
--
-- スクロール/内容同期は vivify.vim の autocmd(ft=markdown で武装)が
-- localhost:PORT へ curl POST する仕組みなので、ペインの iframe(=ws接続する
-- Vivify ページ)にもそのまま効く。ここは「どこに表示するか」だけを担う。

local M = {}

local PORT = 31622
-- systemd --user 起動の nvim-server は PATH に ~/.local/bin を含まないことが
-- あるので絶対パスで叩く。
local SERVER = vim.fn.expand('~/.local/bin/vivify-server')

-- bare サーバを確保(冪等)。未起動なら listen する。起動済みなら新プロセスは
-- 起動時の /health 検知でクライアント動作→即終了するので二重起動にならない。
-- ブラウザは開かない(target 無しなので openFileAt が走らない)。
local function ensure_server()
    if vim.fn.executable(SERVER) == 1 then
        vim.fn.jobstart({ SERVER }, { detach = true })
    else
        vim.notify('vivify-server が見つかりません（vivify/install.sh 未実行?）', vim.log.levels.WARN)
    end
end

-- 指定パスを Vivify で開く（web=右ペイン / 端末=ブラウザタブ）。auto描画はしない。
-- SVG を開くと Vivify がそのファイルを監視し、再生成(上書き)で自動リロード＝ライブプレビュー。
function M.open_path(path)
    if not path or path == '' then return end
    local ch = vim.g.nvim_server_channel
    if type(ch) == 'number' and ch > 0 then
        ensure_server()
        local url = string.format('http://localhost:%d/viewer%s', PORT, path)
        vim.defer_fn(function()
            vim.rpcnotify(ch, 'web_open_url', url, 'Vivify')
        end, 700)
    else
        local viv = vim.fn.exepath('viv')
        if viv == '' then viv = vim.fn.expand('~/.local/bin/viv') end
        vim.fn.jobstart({ viv, path }, { detach = true })
    end
end

function M.open()
    local ch = vim.g.nvim_server_channel
    local web = type(ch) == 'number' and ch > 0

    if not web then
        -- 端末/Neovide: 従来どおりブラウザタブ（vivify.vim を cmd ロード）
        vim.cmd('Vivify')
        return
    end

    local path = vim.fn.expand('%:p')
    if path == '' then
        vim.notify('ファイルが保存されていません', vim.log.levels.WARN)
        return
    end

    ensure_server()
    -- パスはフルパスで渡す（サーバが preferHomeTilde で ~ 形へリダイレクト。
    -- ws 登録パスと sync POST 先は共に urlToPath 解決で一致する）。
    local url = string.format('http://localhost:%d/viewer%s', PORT, path)
    -- 初回起動直後は listen まで数百ms要る（起動済みなら実質待たない）。
    vim.defer_fn(function()
        vim.rpcnotify(ch, 'web_open_url', url, 'Vivify')
    end, 700)
end

return M
