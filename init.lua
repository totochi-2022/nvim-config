-- Neovim初期化設定
vim.loader.enable()

-- 基本設定の即時ロード
require('01_initial_setting')
require('02_option')

-- 残りも即時ロードする。以前は vim.defer_fn(..., 0) で遅らせていたが、
-- 「0 ms」は「イベントループに戻った瞬間」の意味で、コマンドラインで渡した
-- ファイル(nvim foo.md)の BufReadPost / FileType はそれより前に終わっている。
-- そのため 14_autocmd.lua 等で登録する autocmd が起動時のファイルに効かず、
-- md の mp(Vivify)・*.nc / *.bas の filetype・fish の mf が静かに死んでいた。
-- 遅延の効果は実測で 30 ms 前後(誤差)だったので外した。
require('00_loader')
