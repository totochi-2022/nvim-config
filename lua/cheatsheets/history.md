# 履歴・コマンドライン チートシート

## コマンドライン履歴

### 履歴ウィンドウ
- `q:` - コマンドライン履歴ウィンドウを開く
- `q/` - 検索履歴ウィンドウを開く（前方検索）
- `q?` - 検索履歴ウィンドウを開く（後方検索）

### 履歴ナビゲーション
- `<C-p>` / `↑` - 前の履歴項目
- `<C-n>` / `↓` - 次の履歴項目
- `<C-r><C-l>` - 現在行をコマンドラインにコピー

### 履歴検索
- `<C-r><C-w>` - カーソル下の単語を検索
- `<C-r><C-a>` - カーソル下のWORDを検索
- `<C-r>"` - レジスタ内容を挿入

## 履歴表示コマンド

### :history コマンド
- `:history` - 全履歴表示
- `:history :` - コマンド履歴のみ
- `:history /` - 検索履歴のみ
- `:history @` - 入力履歴のみ
- `:history -5` - 最新5件の履歴

### 履歴クリア
- `:call histdel(":")` - コマンド履歴をクリア
- `:call histdel("/")` - 検索履歴をクリア
- `:call histdel("@")` - 入力履歴をクリア

## コマンドライン編集

### カーソル移動
- `<C-b>` / `<Home>` - 行頭へ
- `<C-e>` / `<End>` - 行末へ
- `<C-h>` / `<BS>` - 前の文字を削除
- `<C-w>` - 前の単語を削除
- `<C-u>` - 行頭まで削除

### 挿入・補完
- `<C-r>=` - 式を評価して挿入
- `<C-r>%` - 現在のファイル名を挿入
- `<C-r>/` - 最後の検索パターンを挿入
- `<Tab>` - ファイル名・コマンド補完

## 便利な履歴機能

### 履歴検索
- `/` 後に `<C-p>` - 部分一致で前の検索履歴
- `:` 後に `<C-p>` - 部分一致で前のコマンド履歴

### 繰り返し実行
- `@:` - 最後のExコマンドを繰り返し
- `@@` - 最後の@コマンドを繰り返し

### レジスタとの連携
- `"` + `<レジスタ>` + `p` - レジスタ内容をコマンドラインに挿入

---

## 設定済みキーマップ（lua/21_keymap.lua）

### コマンドライン履歴
- `q;` - `q:` コマンド履歴 (line:122)
- `<LocalLeader>;` - `q:` コマンドライン履歴 (line:123)
- `<Leader>;` - `:` コマンド入力 (line:121)
- `;` - `:` 洗練されたコマンドライン（FineCmdline） (line:124-125)

### ヤンク履歴
- `<Leader>p` - `:Telescope yank_history` ヤンク履歴 (line:133)
- `<C-n>` - `<Plug>(YankyCycleForward)` ヤンク履歴を次へ (line:322)
- `<C-p>` - `<Plug>(YankyCycleBackward)` ヤンク履歴を前へ (line:323)

### その他の履歴機能
- `<Leader>Q` - `:Telescope quickfixhistory` クイックフィックス履歴 (line:148)
- `<Leader>u` - `:Telescope undo` 変更履歴（Telescope） (line:156)
- `mgD` - `:DiffviewFileHistory %` ファイル履歴 (line:335)

### メッセージ履歴
- `<LocalLeader>m` - `:messages` メッセージ履歴表示 (line:369)
- `<LocalLeader>nh` - `require("noice").cmd("history")` メッセージ履歴 (line:456)

### 検索関連
- `*` - カーソル下の単語を前方検索
- `#` - カーソル下の単語を後方検索
- `g*` - 部分一致で前方検索
- `g#` - 部分一致で後方検索

---

## 履歴設定

### 履歴サイズ
```lua
vim.o.history = 1000  -- 履歴保存数
```

### 履歴保存場所
- コマンド履歴: `~/.local/share/nvim/shada` に保存
- 設定で永続化可能

---

## プラグイン連携

### Telescope履歴検索
- `:Telescope command_history` - コマンド履歴検索
- `:Telescope search_history` - 検索履歴検索
- `:Telescope yank_history` - ヤンク履歴（yanky.nvim連携）
- `:Telescope undo` - アンドゥ履歴（telescope-undo.nvim）

### Yanky.nvim
- ヤンクリングによる履歴管理
- `<C-n>/<C-p>` でヤンク履歴を循環
- Telescope統合で検索可能

### Noice.nvim
- メッセージ履歴の改良表示
- `<LocalLeader>nh` で履歴表示

---

## トラブルシューティング

### 履歴が保存されない
1. `shada` ファイルの権限を確認
2. `:set shada?` で設定を確認
3. `:wshada!` で強制保存

### 履歴ウィンドウでの編集
- 履歴ウィンドウでは通常のVimコマンドが使用可能
- `<Enter>` でコマンド実行
- `:q` でウィンドウを閉じる

### コマンドライン補完（noice.nvim）
- **既知の問題**: Enterキーでの補完選択ができない
- **回避策**: スペースキーで補完を確定
- 参考: GitHub Issue #1142