# LSP 機能

`m` プレフィックス（デフォルトの `m` マッピングは無効化し LSP 用に解放済み）。

## ナビゲーション（Telescope版・常時有効）

| キー | 動作 | 説明 |
|------|------|------|
| `md` | 定義一覧 | `:Telescope lsp_definitions` |
| `mD` | 宣言一覧 | `:Telescope lsp_declarations` |
| `mt` | 型定義一覧 | `:Telescope lsp_type_definitions` |
| `mrr` | 参照一覧 | `:Telescope lsp_references` |
| `mri` | 実装一覧 | `:Telescope lsp_implementations` |
| `mra` | コードアクション | `:Telescope lsp_code_actions` |
| `mO` | ドキュメントシンボル | `:Telescope lsp_document_symbols` |
| `mS` | ワークスペースシンボル | `:Telescope lsp_workspace_symbols` |

## 情報表示（LspAttach時）

| キー | 動作 | 説明 |
|------|------|------|
| `m<Space>` | ホバー情報 | `vim.lsp.buf.hover()` |
| `<C-Space>` | ホバー情報 | 同上 |
| `mh` | シグネチャヘルプ | `vim.lsp.buf.signature_help()` |

※ 自動ホバー（toggle: h）を ON にするとカーソル停止で自動表示。

## 編集・診断（LspAttach時）

| キー | 動作 | 説明 |
|------|------|------|
| `mf` | フォーマット | `vim.lsp.buf.format({async=true})` |
| `mrn` | リネーム | `vim.lsp.buf.rename()` |
| `me` | 診断をフロート表示 | `vim.diagnostic.open_float()` |
| `mq` | 診断を loclist へ | `vim.diagnostic.setloclist()` |

## ワークスペースフォルダ

| キー | 動作 |
|------|------|
| `mwa` | フォルダ追加 |
| `mwr` | フォルダ削除 |
| `mwl` | フォルダ一覧表示 |

## 診断ジャンプ（DIAGNOSTICモード）

`mo`（次）/ `mi`（前）でモード開始。以降は単キーで連続ジャンプ（永続モード、`q`/`Esc`で終了、`?`でヘルプ）。

| キー | 動作 |
|------|------|
| `o` / `i` | 次 / 前の診断（全種類） |
| `n` / `p` | 次 / 前の ERROR |
| `k` / `j` | 次 / 前の WARN |
| `>` / `<` | 次 / 前の INFO |
| `.` / `,` | 次 / 前の HINT |

## Telescope 一覧

| キー | 動作 |
|------|------|
| `<Leader>d` | `:Telescope diagnostics` 診断一覧 |
| `<Leader>A` | `:Telescope lsp_<Tab>` LSP機能一覧 |

## 補完・管理

| キー / コマンド | 動作 |
|------|------|
| `:Mason`（`<F8>m`） | LSP/フォーマッタ管理 |
| `:LspInfo` | アタッチ中のサーバ確認 |

---
💡 **Tips**:
- 定義へ飛んだら `<C-o>`（toggle: j 設定に応じ file_local/global）で戻れる
- フォーマットは Fish では `fish_indent` が優先される
- 診断表示の濃さは toggle: `d`（signs_only / cursor_only / full_with_underline）で切替
