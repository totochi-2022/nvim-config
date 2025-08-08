# Neovim設定ドキュメント

このドキュメントは、Claudeに依頼する際の参考情報として、Neovim環境の構成と設定を記載しています。

## 環境情報

- **OS**: Windows (WSL2 - Linux 5.15.133.1-microsoft-standard-WSL2)
- **設定場所**: 
  - Windows側: `/mnt/c/Users/tanaka/AppData/Local/nvim/`
  - Linux側: `/home/motoki/.config/nvim/` (同期されている)
- **プラグインマネージャー**: lazy.nvim
- **lazy.nvimプラグイン保存場所**: `~/.local/share/nvim/lazy/`
  - 各プラグインはこのディレクトリ配下にgitリポジトリとして保存される
  - 例: `~/.local/share/nvim/lazy/incsearch.vim/`

## ディレクトリ構造

```
nvim/
├── init.lua                    # メインエントリーポイント
├── lua/
│   ├── 00_loader.lua          # ローダー設定
│   ├── 01_initial_setting.lua # 初期設定
│   ├── 02_option.lua          # Neovimオプション設定
│   ├── 03_function.lua        # カスタム関数定義
│   ├── 11_plugin.lua          # プラグインマネージャー設定
│   ├── 12_toggle.lua          # トグル設定
│   ├── 13_lsp.lua            # LSP設定
│   ├── 14_autocmd.lua        # 自動コマンド設定
│   ├── 15_dap.lua            # デバッグ設定
│   ├── 21_keymap.lua         # キーマップ設定
│   ├── plugins/              # 機能別プラグイン設定
│   │   ├── core.lua          # コア機能
│   │   ├── debug.lua         # デバッグ関連
│   │   ├── editor.lua        # エディタ機能
│   │   ├── git.lua           # Git統合
│   │   ├── lsp.lua           # LSP関連プラグイン
│   │   ├── misc.lua          # その他
│   │   ├── motion.lua        # モーション・移動
│   │   ├── terminal.lua      # ターミナル統合
│   │   └── ui.lua            # UI関連
│   └── rc/
│       ├── minor_mode.lua    # マイナーモード設定
│       └── toggle.lua        # トグルライブラリ
├── data/                     # データディレクトリ
│   ├── bookmark/             # ブックマーク
│   ├── howm/                 # メモデータ
│   ├── junk/                 # 一時ファイル
│   └── setting/              # 設定保存ディレクトリ
│       └── toggle/           # トグル関連設定
│           ├── states.json   # トグル状態保存
│           └── lualine.json  # lualine表示設定
├── nvim-data/               # Neovimデータ
├── plugin/                  # プラグインディレクトリ
└── lazy-lock.json          # プラグインのロックファイル
```

## ディレクトリ構成ルール

### lua/ ディレクトリ
- **番号付きファイル**: 読み込み順序を制御するメイン設定ファイル
  - `00-09`: 基本設定（loader, initial, option, function）
  - `10-19`: プラグイン・機能設定（plugin, toggle, lsp, autocmd, dap）
  - `20-29`: UI・キーマップ設定（keymap）
- **plugins/**: 機能別プラグイン設定（lazy.nvim用）
- **rc/**: 再利用可能なライブラリ・ユーティリティ

### data/ ディレクトリ
- **bookmark/, howm/, junk/**: 既存のユーザーデータ
- **setting/**: アプリケーション設定の保存場所
  - **toggle/**: トグル機能関連の設定・状態保存
  - その他の機能別ディレクトリを今後追加可能

### ファイル配置の指針
- **設定ファイル**: `lua/` 配下に配置
- **状態保存ファイル**: `data/setting/` 配下に機能別ディレクトリを作成
- **一時ファイル**: `data/junk/` 配下に配置
- **ユーザーデータ**: `data/` 直下または適切なサブディレクトリ

## 設定ファイルの読み込み順序

ファイル名の番号順に読み込まれます：
1. `00_loader.lua` - 基本的なローダー設定
2. `01_initial_setting.lua` - 初期化処理
3. `02_option.lua` - Neovimのオプション設定
4. `03_function.lua` - ユーティリティ関数
5. `11_plugin.lua` - プラグインの読み込みと設定
6. `13_lsp.lua` - Language Server Protocol設定
7. `14_autocmd.lua` - 自動コマンド
8. `15_dap.lua` - デバッグアダプター設定
9. `21_keymap.lua` - キーマッピング

## よくある問題と解決方法

### 1. Nerd Fontアイコンが表示されない

**症状**: ファイルアイコンや記号が文字化けする

**解決方法**:
- Nerd Font対応のフォントをインストール
- ターミナルのフォント設定を確認
- `nerd_font_fix_progress.md`に修正履歴あり

### 2. プラグインが読み込まれない

**症状**: 特定のプラグインが機能しない

**確認事項**:
- `lazy-lock.json`でプラグインバージョンを確認
- `:Lazy`コマンドでプラグインの状態を確認
- `11_plugin.lua`と`plugins/`配下の設定を確認

### 3. LSPが動作しない

**症状**: 補完やエラー表示が機能しない

**確認事項**:
- `13_lsp.lua`の設定を確認
- 必要なLanguage Serverがインストールされているか確認
- `:LspInfo`でLSPの状態を確認

### 4. キーマップの競合

**症状**: 期待したキーマップが動作しない

**解決方法**:
- `21_keymap.lua`でキーマップ設定を確認
- `:verbose map <key>`で競合を調査
- which-keyプラグインの設定を確認

## 設定変更時の注意事項

1. **ファイルの命名規則を守る**: 番号付きファイルは読み込み順序に影響
2. **プラグイン設定は適切なディレクトリに**: 機能別に`plugins/`配下に配置
3. **両環境の同期**: Windows側とLinux側の設定を同期させる
4. **lazy.nvimの更新**: プラグイン追加後は`:Lazy sync`を実行

## 頻繁に修正する設定

- **キーマップ設定**: `21_keymap.lua`
- **プラグイン追加**: `11_plugin.lua`と`plugins/`配下
- **LSP設定**: `13_lsp.lua`と`plugins/lsp.lua`
- **UI関連**: `plugins/ui.lua`

## Git ブランチ運用ルール

### 基本方針
- **個人開発**: 小さな変更は `main` ブランチで直接作業
- **大きな変更**: 機能ブランチを作成してから `main` にマージ

### ブランチ命名規則
```bash
# Claude Code での作業
claude-coding

# 機能追加
feature/機能名

# バグ修正  
fix/修正内容

# 実験的変更
experiment/試行内容
```

### Claude Code 専用ブランチ
```bash
# Claude Code セッション開始時
git checkout -b claude-coding

# 作業完了後
git checkout main
git merge claude-coding
git branch -d claude-coding

# 次回セッション（同じ名前で再利用可能）
git checkout -b claude-coding
```

### ブランチ作成の判断基準
**ブランチを作成する場合:**
- 複数ファイルにまたがる大きな変更
- 新機能の追加（今回のトグルライブラリなど）
- 実験的な変更（失敗したら捨てたい）
- Claude Code での作業

**main で直接作業する場合:**
- 小さな設定変更
- タイポ修正
- 1ファイルのみの軽微な変更

### マージ後の処理
- 作業完了したブランチは削除
- ブランチ名は再利用可能
- 履歴はコミットメッセージで管理

## デバッグ用コマンド

```vim
:checkhealth          " 環境の健全性チェック
:Lazy                 " プラグインマネージャーUI
:LspInfo             " LSPの状態確認
:verbose map         " キーマップの確認
:messages            " エラーメッセージの確認
```