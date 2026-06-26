# トグル機能（toggle-manager）

`<LocalLeader>0`（= `<Space>0`）で統合トグルメニューを開き、各キーで状態を切り替える。
状態は lualine に表示される（最初の状態のものは自動非表示）。

## トグル一覧

| キー | 名前 | 状態 | デフォルト | 説明 |
|------|------|------|-----------|------|
| `d` | diagnostics | signs_only / cursor_only / full_with_underline | signs_only | 診断表示の濃さ（⚠） |
| `p` | paste_mode | off / on | off | ペーストモード（󰆒） |
| `h` | auto_hover | off / on | off | カーソル停止で自動ホバー（🎈） |
| `c` | colors | off / on(all) | on | カラーコードの色表示（） |
| `m` | migemo | off / on | off | ローマ字で日本語検索（み） |
| `f` | quickscope | off / on | on | f/F移動時のハイライト |
| `j` | jump_mode | global / file_local | file_local | `<C-o>/<C-i>` をファイル内限定にするか（󱀼） |
| `n` | noice_mode | off / all / below | all | Noice 表示モード（💬） |
| `l` | laststatus | 2 / 3 | 3 | ステータスライン表示 |
| `v` | cursorcolumn | off / on | off | カーソル縦ライン（󰥓） |

## 各トグルの効果

- **d (diagnostics)**: `signs_only`=サインのみ / `cursor_only`=カーソル行のみinline / `full_with_underline`=virtual text+下線
- **j (jump_mode)**: `file_local` 時は `<C-o>/<C-i>` が現在ファイル内のみジャンプ（`:FileJumpBack/Forward`）。`global` で通常の Vim ジャンプリスト（ファイル間移動可）
- **m (migemo)**: ON で `/` `?` `g/` が migemo 検索に置換、EasyMotion も日本語対応
- **n (noice_mode)**: `all`=フローティングcmdline+LSP進捗+通知 / `below`=下部cmdline+通知のみ / `off`=Noice無効（トラブル時）
- **c (colors)**: nvim-highlight-colors / mini.hipatterns によるカラーコード可視化

---
💡 **Tips**:
- メニューを開かずキーを覚えていれば `<LocalLeader>0` → 該当キーで即トグル
- 日本語検索したいとき `m`、画面が乱れたら `n` を `all` に入れ直すと回復することが多い
- 関連: 検索は [search.md]、診断ジャンプは [lsp.md] 参照
