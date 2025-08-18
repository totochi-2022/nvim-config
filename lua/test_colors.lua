-- カラーテストファイル
-- nvim-highlight-colorsプラグインの動作確認

-- HEXカラー（動作確認済み）
local hex_color = "#FF0000"  -- 赤
local short_hex = "#0F0"     -- 緑

-- 名前付き色
local named_red = 'red'
local named_blue = 'blue'
local named_green = 'green'
local named_yellow = 'yellow'

-- RGBカラー
local rgb_color = 'rgb(255 0 0)'
local rgb_blue = 'rgb(0 0 255)'

-- HSLカラー
local hsl_color = 'hsl(0deg 100% 50%)'

-- Tailwindクラス（有効化済み）
local tailwind_bg = 'bg-blue-500'
local tailwind_text = 'text-red-600'

-- Vimハイライトグループ
local highlight1 = "DiagnosticError"
local highlight2 = "DiagnosticHint"
local highlight3 = "Comment"
local highlight4 = "String"

-- 直接の色指定（値の部分に色が表示される）
local color1 = 'red'       -- ← 'red'に赤い■
local color2 = 'blue'      -- ← 'blue'に青い■
local color3 = '#00FF00'   -- ← '#00FF00'に緑の■
local color4 = 'rgb(255 255 0)'  -- ← 黄色の■