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
| `<Leader>c` | Claude タスク一覧 | `:ClaudePick`（dtach 永続セッション）／`変換+c` |
| `変換+b` | Claude の右 dock を 差分⇔Board 切替 | Claude 端末へ `/board` を送る（入力欄が空の時に使う） |
| `<Leader>C` | 現プロジェクトで起動 | `:ClaudeOpen` |

俯瞰ボードは Claude Code 側の mod に移した（`/board` で開閉、`/board auto on|off` で起動時に開くかを決める。
実体は `~/.claude_plugin/mods/session-board`）。


タスク一覧（`:ClaudePick`）の中のキー:

| キー | 動作 |
|------|------|
| `Enter` | 開く（稼働中→attach / 停止中→起動。過去ログがあれば `--continue`＋再開見出し） |
| `C-s` | **そのフォルダのセッションを id 一覧から選ぶ**（`:ClaudeSessions`。⌨入力待ち 💤待機 ⏳作業中 ✔完了。ジョブ→`claude attach` / 稼働中→その slot / 停止中→`--resume <id>`） |
| `C-n` | **一覧に無いフォルダで新規**（パス入力・既定=cwd・`<Tab>` 補完。無ければ確認して mkdir） |
| `C-f` | 会話モード(fork)を同フォルダに新規起動 |
| `C-v` | 左の縦分割で開く |
| `C-x` / `C-d` | exit&save / 強制 kill |
| `C-a` | 起動中を一括 exit&save |

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
- `<Leader>c`（ClaudePick）は dtach で生き続けるセッション一覧
- web版に飛ばすときは `:ToServer`、戻すときは `<Leader>0`
