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

## TreeSitter テキストオブジェクト（nvim-treesitter-textobjects）

構文ベース。パーサのある言語で関数・クラス等を正確に選択。`select.lookahead=true`
なので対象が少し先にあっても賢くジャンプして選択する。

| オブジェクト | 内側 / 外側 | 説明 |
|------|------|------|
| 関数 | `if` / `af` | inner / a function |
| クラス | `ik` / `ak` | inner / a class（k=klass） |
| ループ | `iL` / `aL` | loop（`il`/`al` は行textobjなので大文字L） |
| 条件分岐 | `io` / `ao` | if/else（o=cOnditional） |
| 引数 | `ia` / `aa` | parameter/argument |

### 関数間ジャンプ（移動）
| キー | 動作 |
|------|------|
| `]m` / `[m` | 次 / 前の関数の先頭へ |
| `]M` / `[M` | 次 / 前の関数の末尾へ |

## 正規表現ベース（nvim-various-textobjs）

TreeSitter不要・全filetypeで動く。インデントや value など標準に無いものを補う。

| オブジェクト | 内側 / 外側 | 説明 |
|------|------|------|
| インデント | `ii` / `ai` | 同インデント / +直上の行（Python/YAML/設定に強力） |
| インデント+上下 | — / `aI` | 上下の囲み行も含める |
| 以下インデント | `R` | カーソル位置から下のインデント全部 |
| value | `iv` / `av` | `key = value` / `key: value` の右辺だけ |
| subword | `iS` / `aS` | camelCase / snake_case の一語分 |
| チェーン要素 | `im` / `am` | `foo.bar().baz` の一区切り |
| 数値 | `iN` / `aN` | 符号・小数も賢く（dial.nvim の `+`/`-` と相性良） |
| 引用符（種類問わず） | `iq` / `aq` | `" ' \`` のどれでも対象 |

※ value の counterpart の key textobj は TS クラス(`ik`/`ak`)とキーが衝突するため未割当て。

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
- Python等インデント言語では `dii`/`vai` が便利。設定ファイルの値だけ変えるなら `civ`
- `cigS`… ではなく subword は `ciS`（`getUserName` の一語だけ変更）
- 構文単位で素早く選ぶなら `<LocalLeader>j`（expand_region）や `<LocalLeader>s`（TS hop）
- 引数は `ia`(TS) か `i,` で選択 → `ms`（ISwap）で入れ替え（plugins.md 参照）
