-- 01_initial_setting.lua
require '01_initial_setting'

-- 02_option.lua
require '02_option'

-- 04_env_check.lua (環境チェック)
require '04_env_check'

-- 11_plugin.lua
require '11_plugin'

-- 12_function.lua（プラグイン読み込み後に実行）
require '12_function'

-- 13_lsp.lua
require '13_lsp'

-- 14_autocmd.lua
require '14_autocmd'

-- 15_dap.lua
require '15_dap'

-- 16_toggle.lua (新トグルシステム) - キーマップより先に読み込み
require '16_toggle'

-- 21_keymap.lua
require '21_keymap'

-- claude_tasks.lua (dtach ベースの Claude Code タスク管理: :ClaudeOpen/:ClaudePick/:ClaudeKill)
require('claude_tasks').setup()

-- file_preview.lua (自作プレビューア呼び出し: :Preview / svg・csv・stl・dxf)
require('file_preview').setup()

-- howm_link.lua (telekasten上で howm の come-from(<<<) 連想リンク: :HowmFollow/:HowmDeclare)
require('howm_link').setup()

-- howm_diary.lua (エントリ単位の日記: :HowmDiary / ,,n で時刻ファイルを作成)
require('howm_diary').setup()

-- session_xfer.lua (ターミナル版nvimのセッションをweb版サーバへ転送: :ToServer)
require('session_xfer').setup()

-- 23_cheatsheet.lua (チートシートシステム)
require '23_cheatsheet'

-- 31_startup.lua (最終起動処理)
require '31_startup'
