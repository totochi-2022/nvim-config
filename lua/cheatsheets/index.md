# Neovim チートシート

`<LocalLeader>?`（= `<Space>?`）で表示されるチートシートメニューの目次。
メニュー上で各キーを押すと対応シートを開く。

## カテゴリ別キーバインド

### 基本操作
- `[j]` [移動・ジャンプ](jump.md) - カーソル移動、ジャンプ/変更リスト、マーク、診断ジャンプ、EasyMotion
- `[v]` [選択・ビジュアル](selection.md) - ビジュアルモード、テキストオブジェクト、surround
- `[t]` [テキストオブジェクト](textobj.md) - 標準/プラグイン/TreeSitter のテキストオブジェクト
- `[f]` [フォールド](fold.md) - コードの折りたたみ（Foldモード）
- `[c]` [コメント](comment.md) - NERDCommenter
- `[m]` [マルチカーソル](multicursor.md) - vim-visual-multi（F4プレフィックス）
- `[h]` [履歴・コマンドライン](history.md) - コマンド/検索/ヤンク履歴、noice
- `[s]` [検索・置換](search.md) - asterisk、grug-far、Telescope grep、quickhl、migemo

### 開発機能
- `[l]` [LSP](lsp.md) - 定義/参照ジャンプ、リネーム、フォーマット、診断（`m`プレフィックス）
- `[g]` [Git](git.md) - fugitive / Gitsigns / Diffview（`mg`プレフィックス）
- `[d]` [デバッグ](debug.md) - nvim-dap（`<F7>`プレフィックス）

### ウィンドウ・環境
- `[w]` [ウィンドウ・バッファ](window.md) - 分割、ウィンドウ管理モード、バッファ移動
- `[T]` [ターミナル・Claude](terminal.md) - 内蔵ターミナル、ClaudeCode、web版転送
- `[o]` [トグル](toggle.md) - toggle-manager（`<LocalLeader>0`）の各トグル
- `[p]` [プラグイン](plugins.md) - Yanky / dial / EasyAlign / howm(telekasten) ほか

---

## クイックアクセス
- `<LocalLeader>?` - このチートシートメニューを表示
- `<LocalLeader>0` - 統合トグルメニュー
- `<LocalLeader><F1><F1>` - WhichKey（全キーマップ）
- `<LocalLeader><F1>s` - Leader(`s`)キーのヘルプ
- `<LocalLeader><F1><Space>` - LocalLeader(Space)キーのヘルプ
- `<Leader>k` - Telescope keymaps（キーマップ全文検索）
- `<Leader>w` - バッファローカルのキーマップ（which-key）

---

## 凡例
- `<Leader>` = **`s`**（`vim.g.mapleader = 's'`）
- `<LocalLeader>` = **`<Space>`**（`vim.g.maplocalleader = ' '`）
- `m` = LSP/Git/プラグイン用プレフィックス（デフォルトの `m` マッピングは無効化済み）
- `<C-x>` = Ctrl+x / `<M-x>` = Alt+x / `<S-x>` = Shift+x
- `{motion}` = 移動コマンド（w, iw, $ 等） / `{char}` = 任意の文字
- `|` = カーソル位置
