# Toggle System Library

Neovimの各種機能を動的に切り替えるためのトグルシステムライブラリです。

## 特徴

- 🎨 **カラフルなlualine表示** - 状態に応じた色付き表示
- 🖼️ **フローティングUI** - 直感的なトグルメニュー
- 🎯 **動的ハイライト** - カラースキーム対応の色設定
- 🔧 **設定分離** - ライブラリと設定の明確な分離
- 💾 **状態保存** - 設定の永続化

## 基本的な使い方

### キーマップ

- `<Space>0` - トグルメニューを開く
- 小文字キー（例：`d`）- 状態切り替え
- 大文字キー（例：`D`）- lualine表示切り替え
- `s` - 現在の状態をデフォルトとして保存

### lualine表示

lualine設定で以下のように使用：

```lua
{
  'nvim-lualine/lualine.nvim',
  config = function()
    require('lualine').setup({
      sections = {
        lualine_x = {
          require('rc.toggle').get_lualine_component(),
          -- 他のコンポーネント...
        }
      }
    })
  end
}
```

## ライブラリAPI

### 基本関数

#### `register_definitions(definitions)`
トグル定義を登録します。

```lua
local toggle = require('rc.toggle')
toggle.register_definitions({
  d = {
    name = 'diagnostics',
    states = {'off', 'on'},
    colors = {
      { fg = 'NonText' },
      { fg = 'Normal', bg = 'DiagnosticError' }
    },
    default_state = 'off',
    desc = '診断表示',
    get_state = function() -- 現在の状態を取得
      return vim.diagnostic.is_disabled() and 'off' or 'on'
    end,
    set_state = function(state) -- 状態を設定
      if state == 'off' then
        vim.diagnostic.disable()
      else
        vim.diagnostic.enable()
      end
    end
  }
})
```

#### `init_highlights()`
ハイライトシステムを初期化します。

```lua
toggle.init_highlights()
```

#### `initialize_toggles()`
トグル定義を初期化し、保存された状態を復元します。

```lua
toggle.initialize_toggles()
```

#### `setup()`
UI機能を初期化します。

```lua
toggle.setup()
```

### UI機能

#### `show_toggle_menu()`
トグルメニューのフローティングウィンドウを表示します。

#### `get_lualine_component()`
lualine用のコンポーネント関数を返します。

### ハイライト機能

#### `get_or_create_highlight(color_def, name, index)`
動的にハイライトグループを作成または取得します。

## トグル定義の書式

### 必須フィールド

- `name` - トグルの内部名
- `states` - 取りうる状態の配列
- `colors` - 各状態に対応する色設定
- `default_state` - デフォルト状態
- `desc` - 説明文
- `get_state()` - 現在の状態を取得する関数
- `set_state(state)` - 状態を設定する関数

### 色設定の方法

#### 1. プリセット使用
```lua
colors = { 'ToggleGray', 'ToggleGreen' }
```

#### 2. ハイライトグループ参照
```lua
colors = {
  { fg = 'NonText' },                    -- NonTextの前景色を使用
  { fg = 'Normal', bg = 'DiagnosticError' } -- Normal文字/DiagnosticError背景
}
```

#### 3. 直値指定（非推奨）
```lua
colors = {
  { fg = '#808080', bg = '#2F2F2F' },
  { fg = '#FFFFFF', bg = '#FF0000' }
}
```

### プリセットハイライトグループ

- `ToggleError` - 赤系（DiagnosticErrorベース）
- `ToggleWarn` - 黄系（DiagnosticWarnベース）
- `ToggleInfo` - 青系（DiagnosticInfoベース）
- `ToggleHint` - 灰系（DiagnosticHintベース）
- `ToggleGreen` - 緑系（MoreMsgベース）
- `ToggleGray` - 灰系（NonTextベース）
- `ToggleVisual` - 選択色系（Visualベース）

## 設定例

```lua
-- 22_toggle.lua での設定例
local M = {}
local toggle_lib = require('rc.toggle')

M.definitions = {
  -- 診断表示
  d = {
    name = 'diagnostics',
    states = {'off', 'on'},
    colors = {
      { fg = 'NonText' },
      { fg = 'Normal', bg = 'DiagnosticWarn' }
    },
    default_state = 'on',
    desc = '診断表示',
    get_state = function()
      return vim.diagnostic.is_disabled() and 'off' or 'on'
    end,
    set_state = function(state)
      if state == 'off' then
        vim.diagnostic.disable()
      else
        vim.diagnostic.enable()
      end
    end
  },
  
  -- 読み取り専用モード
  r = {
    name = 'readonly',
    states = {'off', 'on'},
    colors = {
      { fg = 'NonText' },
      { fg = 'WarningMsg', bg = 'Visual' }
    },
    default_state = 'off',
    desc = '読み取り専用',
    get_state = function()
      return vim.opt.readonly:get() and 'on' or 'off'
    end,
    set_state = function(state)
      vim.opt.readonly = (state == 'on')
    end
  }
}

-- 初期化
vim.defer_fn(function()
  toggle_lib.register_definitions(M.definitions)
  toggle_lib.init_highlights()
  toggle_lib.initialize_toggles()
  toggle_lib.setup()
end, 100)

return M
```

## ファイル構成

```
lua/
├── rc/
│   ├── toggle.lua          # ライブラリ本体
│   └── README.md          # このファイル
├── 22_toggle.lua          # ユーザー設定
└── data/setting/toggle/   # 設定保存ディレクトリ
    ├── defaults.json      # デフォルト状態
    └── lualine_display.json # lualine表示設定
```

## トラブルシューティング

### lualineに表示されない

1. トグルメニュー（`<Space>0`）で大文字キーを押して表示をオンに
2. lualineの設定でコンポーネントが正しく追加されているか確認
3. `:lua print(vim.inspect(require('rc.toggle').get_definitions()))` で定義を確認

### 色が表示されない

1. ハイライトグループが正しく作成されているか確認
2. カラースキーム変更後は自動的に再作成されます
3. 直値指定ではなくハイライトグループ参照を使用

### 状態が保存されない

1. `data/setting/toggle/` ディレクトリの権限を確認
2. トグルメニューで `s` キーを押してデフォルトを保存

## ライセンス

このコードはpublic domainです。自由にご利用ください。