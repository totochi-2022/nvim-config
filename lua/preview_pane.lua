-- preview_pane.lua
-- nvim-server(web版) のプレビューペイン操作。実体は web クライアント側にあるので、
-- ここは g:nvim_server_channel 経由で RPC を投げるだけ。端末(web非接続)では no-op。
--
--   resize(delta) : 幅を delta ステップ調整（ss モードの ]/[ から。1=広げる/-1=狭める）
--   reset()       : 既定幅へ
--   close()       : ペインを閉じる（ss モードの p から）
--   set_follow(on): md バッファ追従モード（<LocalLeader>0 のトグル, 方式B）
--                   ON 中は md バッファに入る度にそのプレビューを web ペインへ出す。

local M = {}

local STEP = 5 -- 1 ステップ = 5%（web 側で解釈・クランプ）

-- web 接続中なら RPC チャンネル、そうでなければ nil
local function chan()
  local c = vim.g.nvim_server_channel
  return (type(c) == "number" and c > 0) and c or nil
end

local function warn_no_web()
  vim.notify("プレビューペインは web(nvim-server)接続時のみ有効です", vim.log.levels.WARN)
end

-- いま web ペインに出しているバッファ（重複 repoint 防止）
local shown_buf = nil

-- delta: ステップ(1=広げる/-1=狭める)。
-- defer=true: ペイン幅(CSS)だけ即時更新し、ターミナルの reflow は保留する。
--   submode 連打用。reflow(nvim_ui_try_resize)は pending 中の minor-mode を中断する
--   ため、連打中は走らせず M.commit()（submode 終了時）でまとめて反映する。
-- defer 省略/false: 従来どおり即 reflow（単発キー用）。
function M.resize(delta, defer)
  local c = chan()
  if not c then
    return warn_no_web()
  end
  if defer then
    M._dirty = true
    vim.rpcnotify(c, "web_preview_resize_css", (delta or 0) * STEP)
  else
    vim.rpcnotify(c, "web_preview_resize", (delta or 0) * STEP)
  end
end

-- 保留(defer)していた幅変更をターミナル reflow に反映。submode の exit hook から呼ぶ。
-- 変更が無ければ何もしない（無駄な reflow を避ける）。
function M.commit()
  if not M._dirty then
    return
  end
  M._dirty = false
  local c = chan()
  if not c then
    return
  end
  vim.rpcnotify(c, "web_preview_commit")
end

function M.reset()
  local c = chan()
  if not c then
    return warn_no_web()
  end
  vim.rpcnotify(c, "web_preview_reset")
end

-- defer=true: ペインは隠す(CSS)が reflow は保留（submode 用、commit で反映）。
-- defer 省略/false: 従来どおり即 reflow。
function M.close(defer)
  shown_buf = nil
  local c = chan()
  if not c then
    return
  end
  if defer then
    M._dirty = true
    vim.rpcnotify(c, "web_preview_close_css")
  else
    vim.rpcnotify(c, "web_preview_close")
  end
end

-- 指定バッファを標準ビューア(Vivify)でペインに出す。バッファ文脈で vivify.open()
-- を呼ぶと web 接続中は右ペインへ web_open_url される（=追従）。
-- （旧: markdown-preview を起動していたが、標準ビューア入替に伴い Vivify へ変更）
local function preview_buf(buf)
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    return
  end
  if vim.bo[buf].filetype ~= "markdown" then
    return
  end
  if buf == shown_buf then
    return -- 既に出している
  end
  shown_buf = buf
  vim.api.nvim_buf_call(buf, function()
    pcall(function() require("vivify").open() end)
  end)
end

local follow_group = "PreviewPaneFollow"

-- 追従モードの ON/OFF（方式B）
function M.set_follow(on)
  vim.g.preview_follow = on and true or false
  local grp = vim.api.nvim_create_augroup(follow_group, { clear = true })

  if not on then
    M.close() -- 追従OFFでペインも閉じる（shown_buf も解除）
    return
  end

  if not chan() then
    warn_no_web() -- web 非接続では追従しても出る先が無い（フラグは立てる）
  end

  vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
    group = grp,
    pattern = "*",
    callback = function(ev)
      if not chan() then
        return
      end
      preview_buf(ev.buf)
    end,
  })

  -- 現在バッファが md なら即追従開始
  local cur = vim.api.nvim_get_current_buf()
  if chan() and vim.bo[cur].filetype == "markdown" then
    preview_buf(cur)
  end
end

return M
