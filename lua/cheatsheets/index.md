# Neovim チートシート

## カテゴリ別キーバインド

### 基本操作
- [移動・ジャンプ](jump.md) - カーソル移動、ジャンプリスト、マーク
- [選択・ビジュアル](selection.md) - テキスト選択、ビジュアルモード操作
- [フォールド](fold.md) - コードの折りたたみ操作
- [コメント](comment.md) - コメントの追加・削除・トグル
- [検索・置換](search.md) - 検索、置換、grep操作

### 開発機能
- [LSP](lsp.md) - 言語サーバー機能
- [Git](git.md) - Git統合機能
- [デバッグ](debug.md) - DAP デバッグ機能

### 編集機能
- [テキストオブジェクト](textobj.md) - vim/nvim テキストオブジェクト
- [ウィンドウ・バッファ](window.md) - ウィンドウ分割、バッファ操作
- [ターミナル](terminal.md) - 内蔵ターミナル操作

### カスタム機能
- [トグル](toggle.md) - toggle-manager機能
- [プラグイン](plugins.md) - 主要プラグインのキーバインド

---

## クイックアクセス
- `<LocalLeader>?` - チートシートメニュー表示
- `<LocalLeader>0` - トグルメニュー
- `<Leader>?` - which-key ヘルプ

---

## 凡例
- `<Leader>` = Space
- `<LocalLeader>` = Space (同じ)
- `<C-x>` = Ctrl+x
- `<M-x>` = Alt+x
- `{motion}` = 移動コマンド（w, iw, $等）
- `{char}` = 任意の文字
- `|` = カーソル位置