# Neovim 設定 TODO

## 現在の作業状況

### x/X キーのundo履歴統合
- **状態**: 保留中
- **問題**: undojoin を使った実装が期待通り動作しない
- **試したアプローチ**:
  1. minor-mode を使った実装 → 失敗
  2. undojoin と defer_fn を使った実装 → 失敗
  3. vim.cmd.undojoin() を直接呼び出す → 失敗
- **現在の設定**: シンプルな `"_x` と `"_X` のマッピングのみ
- **今後の検討事項**: 
  - 別のアプローチを調査する必要あり
  - カウント指定（例: 5x）での削除は自然にundo統合される

## 完了したタスク
- [x] 12_function.lua のクリーンアップ
- [x] 21_keymap.lua で x/X のマッピングを簡潔に設定

## 今後のタスク
- [ ] x/X のundo履歴統合の別解決策を調査
- [ ] トグル機能の window-local オプション対応改善
- [ ] 診断表示モードの改善
- [ ] LSPホバーの「No information available」メッセージ抑制
  - vim.lsp.handlers["textDocument/hover"]のオーバーライドを試したが動作せず
  - ハンドラー設定タイミングやLSP初期化順序の調査が必要
  - 代替案：カスタム:Messagesコマンドでフィルタリング表示