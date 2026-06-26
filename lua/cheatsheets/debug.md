# デバッグ（nvim-dap）

`<F7>` プレフィックスでデバッグモード開始（マイナーモード）。

## 基本操作（`<F7>` モード）

| キー | 動作 | 説明 |
|------|------|------|
| `b` | ブレークポイントトグル | `dap.toggle_breakpoint()` |
| `B` | 条件付きブレークポイント | 条件を入力して設定 |
| `c` | 実行継続 | `dap.continue()`（デバッグ開始/再開） |
| `i` | ステップイン | `dap.step_into()` |
| `o` | ステップオーバー | `dap.step_over()` |
| `O` | ステップアウト | `dap.step_out()` |
| `l` | 最後の実行を再開 | `dap.run_last()` |
| `r` | REPL 表示 | `dap.repl.open()` |
| `t` | 終了 | `dap.terminate()` |
| `u` | デバッグUIトグル | `dapui.toggle()` |
| `w` | 変数情報（ホバー） | `dap.ui.widgets.hover()` |
| `s` | スコープ表示 | centered_float(scopes) |

## デバッグUI

| キー | 動作 |
|------|------|
| `<LocalLeader>d` | デバッグUIトグル（`dapui.toggle()`） |
| `<F7>u` | 同上 |

## Python 用（`<F7>p` モード）

| キー | 動作 |
|------|------|
| `r` | 最後の実行を再開 |
| `d` | 選択範囲をデバッグ（`debug_selection`） |
| `t` | テストメソッド実行（`test_method`） |
| `c` | テストクラス実行（`test_class`） |

## Rust 用（`<F7>r` モード）

| キー | 動作 |
|------|------|
| `r` | 最後の実行を再開 |
| `m` | カーソル位置まで実行（`run_to_cursor`） |

---
💡 **Tips**:
- まず `<F7>b` でブレークポイント → `<F7>c` で起動、が基本
- `<F7>u`（または `<LocalLeader>d`）で変数・スタック・REPL のUIを開く
- マイナーモード中は `?` でヘルプ、`q`/`Esc` で抜ける
