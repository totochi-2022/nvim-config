# テキストオブジェクト

`d`/`c`/`y`/`v` などのオペレータと組み合わせて使う。`i`=inner（内側）、`a`=a/around（外側・区切り含む）。

## 標準テキストオブジェクト

| オブジェクト | 内側 / 外側 | 説明 |
|------|------|------|
| 単語 | `iw` / `aw` | word（空白の扱いが異なる） |
| WORD | `iW` / `aW` | 空白区切りの大きな単語 |
| `" ' \`` | `i"` / `a"` 等 | クォート内 / 全体 |
| `( ) b` | `i(` / `a(` | 括弧内 / 全体 |
| `{ } B` | `i{` / `a{` | 波括弧内 / 全体 |
| `[ ]` | `i[` / `a[` | 角括弧内 / 全体 |
| `< >` | `i<` / `a<` | 山括弧内 / 全体 |
| タグ | `it` / `at` | HTML/XMLタグ内 / 全体 |
| 段落 | `ip` / `ap` | 空行で区切られた段落 |
| 文 | `is` / `as` | センテンス |

## プラグイン拡張

| オブジェクト | 内側 / 外側 | プラグイン |
|------|------|------------|
| 行 | `il` / `al` | vim-textobj-line |
| バッファ全体 | `ie` / `ae` | vim-textobj-entire |
| 任意の括弧 | `ib` / `ab` | vim-textobj-anyblock |
| 複数括弧 | `iB` / `aB` | vim-textobj-multiblock |
| パラメータ（引数） | `i,` / `a,` | vim-textobj-parameter |
| コメント | `ic` / `ac` | vim-textobj-comment |

## TreeSitter テキストオブジェクト

| オブジェクト | 内側 / 外側 | 説明 |
|------|------|------|
| 関数 | `if` / `af` | inner / a function |
| クラス | `ic` / `ac` | inner / a class |
| 条件分岐 | `ii` / `ai` | if 文 |
| ループ | `il` / `al` | loop |

※ プラグイン間で `ic`/`il` 等のキーが重複する場合がある。filetype に応じて有効なものが優先される。

## TreeSitter ユニット（treesitter-unit）

| キー | 動作 | 説明 |
|------|------|------|
| `oiu` | ユニット内選択（操作） | オペレータ待機で構文ユニット内 |
| `oau` | ユニット全体選択（操作） | 構文ユニット全体 |

## TreeSitter Hop（tsht）

| キー | 動作 |
|------|------|
| `<LocalLeader>s`（n/x/o） | 構文ノードをラベルジャンプで選択 |

## スマート選択拡張（expand_region）

`<LocalLeader>j` でモード開始。

| キー | 動作 |
|------|------|
| `j` | 選択範囲を広げる |
| `J` / `k` | 選択範囲を狭める |

---
💡 **Tips**:
- `ci(`（括弧内変更）、`dap`（段落削除）、`yaf`（関数まるごとヤンク）が定番
- 構文単位で素早く選ぶなら `<LocalLeader>j`（expand_region）や `<LocalLeader>s`（TS hop）
- 引数の入れ替えは `i,` で選択 → `ms`（ISwap）も便利（plugins.md 参照）
