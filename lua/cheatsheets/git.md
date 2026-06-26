# Git 操作

`mg` プレフィックス。fugitive / Gitsigns / Diffview の統合。

## ステータス・差分・履歴（fugitive / Diffview）

| キー | 動作 | コマンド |
|------|------|----------|
| `mgs` | Git status | `:Git` |
| `mgd` | 差分を分割表示 | `:Gdiffsplit` |
| `mgD` | ファイル履歴 | `:DiffviewFileHistory %` |
| `mgb` | blame | `:Git blame` |
| `mgl` | log（oneline） | `:Git log --oneline` |

## Hunk 操作（Gitsigns）

| キー | 動作 | コマンド |
|------|------|----------|
| `mgp` | Hunk プレビュー | `:Gitsigns preview_hunk` |
| `mgh` | Hunk をステージ | `:Gitsigns stage_hunk` |
| `mgr` | Hunk をリセット | `:Gitsigns reset_hunk` |
| `mgc` | 現在行 blame 表示トグル | `:Gitsigns toggle_current_line_blame` |

## Hunk 移動（GitHunkモード）

`mgj`（次）/ `mgk`（前）で Hunk へ移動しモード開始。以降は単キーで連続移動。

| キー | 動作 |
|------|------|
| `j` | 次の Hunk へ |
| `k` | 前の Hunk へ |
| `q` / `Esc` | モード終了 |
| `?` | ヘルプ表示 |

## よく使う fugitive コマンド（`:Git` バッファ内）

| キー | 動作 |
|------|------|
| `s` | ステージ |
| `u` | アンステージ |
| `=` | inline diff トグル |
| `cc` | コミット |
| `dd` / `dv` | diff（分割/縦分割） |

---
💡 **Tips**:
- まず `mgs` で status を開き、`s`/`u` でステージ操作 → `cc` でコミットが基本フロー
- 1ファイルの変更履歴を追うなら `mgD`（Diffview）が見やすい
- 個別の Hunk を戻したいときは `mgr`、部分採用は `mgh` でステージ
