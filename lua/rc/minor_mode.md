# Minor Mode Library

Neovim用のモーダルキーバインディングシステム。Vimの`<Plug>`マッピング機能を活用してキーシーケンスを実現します。

## 概要

Minor Modeライブラリは、一時的なキーマップモードを作成するためのツールです。特定のプレフィックスキーを押した後、連続してキー操作を行えるモードを提供します。

### 主要機能

- **エントリーポイント**: モードを開始するキー（複数設定可能）
- **モード内アクション**: モード内で繰り返し実行可能なキー
- **フック機能**: モード開始/終了時やアクション毎の処理
- **ヘルプ表示**: `?`キーでキーマップ一覧を表示
- **WhichKey統合**: which-keyプラグインとの連携
- **バリデーション**: 設定の妥当性チェック

## 基本的な使用方法

```lua
local minor_mode = require('rc.minor_mode')

minor_mode.define_mode({
    namespace = 'GitHunk',  -- モード名（必須）
    entries = {
        { key = 'mgh', desc = 'Git Hunk Mode' }  -- エントリーポイント
    },
    actions = {
        { key = 'j', action = '<cmd>Gitsigns next_hunk<CR>', desc = 'Next hunk' },
        { key = 'k', action = '<cmd>Gitsigns prev_hunk<CR>', desc = 'Prev hunk' },
        { key = 'p', action = '<cmd>Gitsigns preview_hunk<CR>', desc = 'Preview' },
        { key = 's', action = '<cmd>Gitsigns stage_hunk<CR>', desc = 'Stage' },
        { key = 'r', action = '<cmd>Gitsigns reset_hunk<CR>', desc = 'Reset' }
    }
})
```

### キーの動作フロー

1. `mgh`を押す → Git Hunkモード開始
2. `j`/`k`で前後のhunkに移動（連続実行可能）
3. `p`でプレビュー、`s`でステージ、`r`でリセット
4. `q`または`Esc`でモード終了

## 設定オプション

### 基本設定

```lua
{
    namespace = 'ModeName',  -- モード名（必須）
    entries = { ... },       -- エントリーポイント（任意）
    actions = { ... },       -- モード内アクション（任意）
    hooks = { ... },         -- フック関数（任意）
    options = { ... }        -- 追加オプション（任意）
}
```

### entries（エントリーポイント）

モードを開始するキーを定義します。

```lua
entries = {
    { 
        key = 'mgh',                    -- キー（必須）
        action = '<cmd>echo "start"<CR>', -- アクション（任意）
        desc = 'Git Hunk Mode',         -- 説明（任意）
        hook = function() ... end       -- 個別フック（任意）
    }
}
```

### actions（モード内アクション）

モード内で実行可能なアクションを定義します。

```lua
actions = {
    {
        key = 'j',                          -- キー（必須）
        action = '<cmd>Gitsigns next_hunk<CR>', -- アクション（必須）
        desc = 'Next hunk',                 -- 説明（任意）
        hook = function() ... end           -- 個別フック（任意）
    }
}
```

### hooks（フック関数）

モード開始/終了時の処理を定義します。

```lua
hooks = {
    enter = function()
        print("モード開始")
        -- モード開始時の処理
    end,
    exit = function()
        print("モード終了")
        -- モード終了時の処理
    end
}
```

### options（追加オプション）

```lua
options = {
    mode = 'n',                      -- 対象モード（デフォルト: 'n'）
    persistent = true,               -- 永続化（デフォルト: true）
    exit_keys = {'<Esc>', 'q'},     -- 終了キー（デフォルト: {'<Esc>', 'q'}）
    use_desc = true,                 -- 説明表示（デフォルト: true）
    show_help_key = '?',            -- ヘルプキー（デフォルト: '?'）
}
```

## 高度な機能

### 複数のエントリーポイント

同じモードに複数の入り口を設定できます。

```lua
entries = {
    { key = 'mgh', desc = 'Git Hunk Mode' },
    { key = '<Leader>gh', desc = 'Git Hunk Mode (Leader)' },
    { key = 'mg]', desc = 'Git Hunk Mode (Bracket)' }
}
```

### フック機能

#### モード全体のフック

```lua
hooks = {
    enter = function()
        -- モード開始時の処理
        vim.cmd('set cursorline')
    end,
    exit = function()
        -- モード終了時の処理  
        vim.cmd('set nocursorline')
    end
}
```

#### アクション毎のフック

```lua
actions = {
    {
        key = 'j',
        action = '<cmd>Gitsigns next_hunk<CR>',
        desc = 'Next hunk',
        hook = function()
            -- このアクション実行後の処理
            print("Next hunk selected")
        end
    }
}
```

### ヘルプ表示

モード内で`?`を押すとヘルプが表示されます。

```
=== GitHunk MODE HELP ===

Entry Points:
  mgh - Git Hunk Mode

Mode Actions:
  j - Next hunk
  k - Prev hunk
  p - Preview
  s - Stage
  r - Reset

Exit Keys:
  <Esc> - モード終了
  q - モード終了
  ? - このヘルプ
```

### 実用例

#### 診断ジャンプモード

```lua
minor_mode.define_mode({
    namespace = 'DiagJump',
    entries = {
        { key = 'md', desc = '診断ジャンプモード' }
    },
    actions = {
        { key = 'j', action = '<cmd>lua vim.diagnostic.goto_next()<CR>', desc = '次の診断' },
        { key = 'k', action = '<cmd>lua vim.diagnostic.goto_prev()<CR>', desc = '前の診断' },
        { key = 'f', action = '<cmd>lua vim.diagnostic.open_float()<CR>', desc = '詳細表示' }
    },
    hooks = {
        enter = function()
            --診断表示をフルモードに切り替え
            require('rc.toggle').set_state('diagnostics', 'full')
        end,
        exit = function()
            -- 元の診断表示に戻す
            require('rc.toggle').set_state('diagnostics', 'underline')
        end
    }
})
```

#### ウィンドウ操作モード

```lua
minor_mode.define_mode({
    namespace = 'Window',
    entries = {
        { key = 'mw', desc = 'ウィンドウ操作モード' }
    },
    actions = {
        { key = 'h', action = '<C-w>h', desc = '左のウィンドウ' },
        { key = 'j', action = '<C-w>j', desc = '下のウィンドウ' },
        { key = 'k', action = '<C-w>k', desc = '上のウィンドウ' },
        { key = 'l', action = '<C-w>l', desc = '右のウィンドウ' },
        { key = '+', action = '<C-w>+', desc = '高さ増加' },
        { key = '-', action = '<C-w>-', desc = '高さ減少' },
        { key = '>', action = '<C-w>>', desc = '幅増加' },
        { key = '<', action = '<C-w><', desc = '幅減少' }
    }
})
```

## 設定のバリデーション

設定に問題がある場合はエラーメッセージが表示されます。

```lua
-- エラー例
minor_mode.define_mode({
    -- namespace が未定義 → エラー
    actions = {
        { key = 'j' } -- action が未定義 → エラー
    }
})
```

エラーメッセージ：
```
minor_mode configuration errors:
namespace is required and cannot be empty
actions[1].action is required
```

## WhichKey統合

which-keyプラグインがインストールされている場合、自動的に連携します。

- エントリーポイントがwhich-keyに登録される
- `desc`フィールドがキー説明として表示される
- v2/v3両方のAPIに対応

## 内部実装

### <Plug>マッピング

内部的に以下の`<Plug>`マッピングを使用：

- `<Plug>(m-p-{namespace})`: モード継続用
- `<Plug>(m-b-{namespace})`: モード開始フック用  
- `<Plug>(m-a-{namespace})`: モード終了フック用

### キーマップの構造

```
エントリーキー → before_hook → アクション → pending
                     ↓
                 タイムアウト設定
                 モード開始メッセージ
                 ユーザーフック実行

モード内キー → アクション → pending（継続）
              
終了キー → after_hook
            ↓
        タイムアウト復元
        モード終了メッセージ
        ユーザーフック実行
```

## トラブルシューティング

### よくある問題

1. **キーが反応しない**
   - namespaceが重複していないか確認
   - キーマップが他のプラグインと競合していないか確認

2. **モードが終了しない**
   - exit_keysの設定を確認
   - persistentオプションの設定を確認

3. **which-keyに表示されない**
   - descフィールドが設定されているか確認
   - which-keyプラグインがインストールされているか確認

### デバッグ方法

```lua
-- キーマップの確認
:verbose map mgh

-- which-keyの確認  
:WhichKey

-- フック関数の動作確認
print(vim.inspect(_G['GitHunk_show_help']))
```

## API リファレンス

### M.define_mode(config)

メインのモード定義関数。

**パラメータ:**
- `config` (table): モード設定

**戻り値:** なし

**例外:** 設定が不正な場合はエラーを投げる

---

このライブラリを使用することで、効率的なキーバインディングシステムを構築できます。