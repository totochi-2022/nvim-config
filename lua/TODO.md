# Neovim設定 TODO

## minor-mode.nvimプラグイン改善

### サイレント機能の追加
- **目的**: x削除モードなど頻繁に使うモードでinfo表示を抑制
- **実装**: `silent = true` オプションを追加
- **使用例**:
  ```lua
  minor_mode.define_mode({
      namespace = 'DeleteMode',
      silent = true,  -- info表示を抑制
      entries = { ... },
      actions = { ... },
  })
  ```
- **効果**: 
  - 頻繁に使うモードでのinfo表示を無効化
  - デバッグ時は `silent = false` で詳細確認可能
- **優先度**: 低（動作に問題ないため）

## その他の改善候補
- （今後追加予定）