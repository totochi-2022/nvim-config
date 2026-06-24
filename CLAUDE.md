# Neovim設定メモ

Claude 向けの最小限のメモ。必要になったら書き足す。

## 環境
- WSL2 (Linux 6.6.x) 上の Neovim。設定は Windows 側 (`/mnt/c/Users/tanaka/AppData/Local/nvim/`) と Linux 側 (`~/.config/nvim/`) で同期。
- プラグインマネージャー: lazy.nvim。プラグイン本体は `~/.local/share/nvim/lazy/`。
- ローカル開発中プラグインは `~/work/repo/` に置き、lazy で `dir = "..."` 参照。

## 構成
- `lua/` 直下の番号付きファイルが読み込み順（小さい番号から）。
- プラグイン設定は機能別に `lua/plugins/` 配下。
- キーマップは `lua/21_keymap.lua` に集約。

## 注意点
- トグル機能では window-local オプション（`wrap`, `number` 等）を避ける。フローティングのトグルメニューから元ウィンドウの状態が取得できず壊れる。必要ならグローバル変数で管理する。
