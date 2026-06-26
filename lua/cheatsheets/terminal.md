# ターミナル・Claude

## 内蔵ターミナル

| キー | 動作 | 説明 |
|------|------|------|
| `<Leader>t` | ターミナル起動 | `:terminal` |
| `<F8>x` | カレントディレクトリで起動 | `:TerminalCurrentDir` |
| `<Esc>` | ノーマルモードへ | `<C-\><C-n>`（ターミナルモード中） |

### ターミナルへの貼り付け（クリップボード）
bracketed paste で囲み、改行を「送信」と誤認させずに貼り付ける。

| キー | 動作 |
|------|------|
| `<C-v>` | クリップボードを貼り付け |
| `<RightMouse>` | 右クリックで貼り付け |
| `<MiddleMouse>` | 中クリックで貼り付け |

※ Windows(PowerShell)では `<C-w>` がウィンドウ操作にマップされる。

## Claude Code

| キー | 動作 | 説明 |
|------|------|------|
| `mz` | Claude トグル | `:ClaudeCode`（パネル表示/非表示） |
| `mx`（v） | 選択を Claude へ送信 | `:ClaudeCodeSend` |
| `<Leader>z` | Claude タスク一覧 | `:ClaudePick`（dtach 永続セッション） |
| `<Leader>Z` | 現プロジェクトで起動 | `:ClaudeOpen` |

## web版 nvim-server 連携

| キー | 動作 | 説明 |
|------|------|------|
| `<Leader>T` | セッションを web版へ転送 | `:ToServer [name]` |
| `<Leader>0` | セッション選択画面へ戻す | nvim は生かしたままブラウザを戻す |
| `<C-l>` | グリッド再計算要求 | 極小サイズで attach した後の手動リカバリ |

## 実行系（QuickRun / Jaq）

| キー | 動作 |
|------|------|
| `mnn` | `:Jaq` 実行（カスタムランナー） |
| `mnf` | `:Jaq float`（フロート・external用） |
| `mnb` | `:Jaq bang`（external用） |
| `mnq` | `:Jaq quickfix`（external用） |
| `mnt` | `:Jaq terminal`（external用） |
| `mnk` / `mnK` | 最新 / 全プロセスを kill |
| `mnl` | `:JaqList` プロセス一覧 |

---
💡 **Tips**:
- TUI（Claude 等）にクリップボードを貼るには `<C-v>` か右/中クリック
- `<Leader>z`（ClaudePick）は dtach で生き続けるセッション一覧
- web版に飛ばすときは `:ToServer`、戻すときは `<Leader>0`
