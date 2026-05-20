# Neovim設定の他環境への導入手順

## 必要な前提条件
- Neovim 0.9以上
- Git
- Node.js (LSP用)
- Deno (denops.vim用)
- ripgrep (検索機能用)
- Nerd Font対応フォント

## 導入手順

### 1. 設定ファイルのバックアップ
既存のNeovim設定がある場合は必ずバックアップを取ってください：
```bash
# Linux/macOS
mv ~/.config/nvim ~/.config/nvim.backup

# Windows
# PowerShellで実行
Move-Item "$env:LOCALAPPDATA\nvim" "$env:LOCALAPPDATA\nvim.backup"
```

### 2. リポジトリのクローン
```bash
# Linux/macOS
git clone <リポジトリURL> ~/.config/nvim

# Windows (PowerShell)
git clone <リポジトリURL> "$env:LOCALAPPDATA\nvim"
```

### 3. 必要なディレクトリの作成
```bash
cd ~/.config/nvim  # またはWindows: cd "$env:LOCALAPPDATA\nvim"
mkdir -p data/bookmark data/howm data/junk data/setting/toggle
mkdir -p nvim-data plugin
```

### 4. Denoのインストール
denops.vimプラグインで必要：

```bash
# Linux/macOS
curl -fsSL https://deno.land/install.sh | sh

# Windows (PowerShell管理者権限)
irm https://deno.land/install.ps1 | iex

# または mise (推奨)
mise install deno@latest
mise use -g deno@latest
```

### 5. プラグインのインストール
Neovimを起動してプラグインを自動インストール：
```bash
nvim
```
初回起動時にlazy.nvimが自動的にインストールされ、プラグインがダウンロードされます。

エラーが出た場合は、Neovim内で以下を実行：
```vim
:Lazy sync
```

### 6. LSPサーバーのインストール
必要な言語サーバーをインストール：

```bash
# TypeScript/JavaScript
npm install -g typescript typescript-language-server

# Python
pip install python-lsp-server

# Lua
# Mason経由でインストール（Neovim内で :Mason を実行）

# その他必要なLSPサーバーを環境に応じてインストール
```

### 7. フォント設定
ターミナルでNerd Font対応フォントを使用するよう設定：
- おすすめ: JetBrains Mono Nerd Font, FiraCode Nerd Font
- ダウンロード: https://www.nerdfonts.com/

### 8. 環境固有の設定調整

#### Windows固有
- `lua/02_option.lua`でシェルコマンドのパスを確認
- PowerShellまたはcmd.exeの設定を調整

#### macOS固有
- クリップボード設定の確認（pbcopyとpbpaste）

#### Linux固有
- クリップボード設定（xclipまたはxsel）のインストール：
```bash
# Ubuntu/Debian
sudo apt install xclip

# Arch
sudo pacman -S xclip
```

### 9. 設定の確認
```vim
:checkhealth
```
を実行して環境の問題を確認・修正

## トラブルシューティング

### プラグインが読み込まれない
```vim
:Lazy clean
:Lazy sync
```

### LSPが動作しない
```vim
:LspInfo
:Mason
```
でインストール状況を確認

### アイコンが文字化けする
- ターミナルのフォント設定を確認
- Nerd Font対応フォントに変更

### パスが見つからないエラー
- `~/work/repo/`などのローカル開発ディレクトリは必要に応じて作成
- または`lua/plugins/`内の該当設定をコメントアウト

## カスタマイズポイント

### 最小構成で始めたい場合
以下のファイルのみコピーして段階的に追加：
- `init.lua`
- `lua/00_loader.lua`
- `lua/01_initial_setting.lua`
- `lua/02_option.lua`
- `lua/11_plugin.lua`（必要なプラグインのみ有効化）

### 特定の機能を無効化
`lua/plugins/`内の不要なファイルを削除またはコメントアウト

## 更新方法
```bash
cd ~/.config/nvim
git pull origin main
nvim +":Lazy sync" +qa
```