# vivify/ — Vivify プレビュー環境の再現用一式

md をレポート化する計画（グラフ/回路図/タイミング図）の閲覧側に Vivify を使う。
本体 `viv`/`vivify-server` はリポ管理外（各マシンでビルド）なので、ここに**再現手順一式**を置く。

## ★ 描画スクリプトは md-preview-kit に分離した
`scripts/`(glue 一式)と `config.json`、`sample.md` は **`~/work/md-preview-kit`**
（[totochi-2022/md-preview-kit](https://github.com/totochi-2022/md-preview-kit)）へ移した。
VS Code 拡張から同じ `glue.js` を消費するため（コピーを持つと drift する）。

ここに残すのは **Vivify 本体まわりだけ**。Vivify は GPL-3.0 なので、パッチを
こちら側に置いたままにして、自作コードの core を混ぜないようにしてある。
`install.sh` は md-preview-kit が無ければ clone し、config をそちらへ symlink する。

## ★ 図・画像ツールは figkit.nvim に独立させた
`render/`(Python→SVG) と `annot/`(marker.js 注釈)、nvim 側の `figure.lua` /
`diagram.lua` / `annotate.lua` は **`~/work/figkit.nvim`**
（[totochi-2022/figkit.nvim](https://github.com/totochi-2022/figkit.nvim)）へ移した。
Vivify に依存しない道具なのに設定リポに同居していたため。

figkit 側の詳細（保存モデル・作業サイズ=出力サイズ・モザイク・`,,p`/`,,e`/`,,s`/`,,m`）は
あちらの README にある。**preview の再読込だけ**は figkit の `on_change` フックから
`require('vivify').reload(buf)` を呼んで繋いでいる（spec は `lua/plugins/misc.lua`）。

`install.sh` の「figure studio 依存」(streamlit/schemdraw/matplotlib/pillow/rdkit, ttyd, tmux)は
figkit 用だが、実機のセットアップを1本にしたいのでここに残してある。

## ファイル
- `install.sh` … 上流 clone → パッチ → SEA ビルド → `~/.local/bin` 導入 →
  md-preview-kit 取得 → `~/.config/vivify/config.json` をそちらへ symlink
- `vivify.patch` … 上流への3点パッチ:
  - `src/app.ts`: 起動時 `/health` プローブに 500ms タイムアウト(mirrored 対策)
  - `src/parser/highlight.ts`: 未知言語フェンスの class に元言語名を残す
    (`<pre class="language-wavedrom">` 等。glue が種別検出できるように)
    ※ VS Code の markdown-it は既定でこの class を吐くので、あちらではパッチ不要
  - `src/parser/markdown.ts`: `import 'katex/contrib/mhchem'` を足して **`\ce{}` を有効化**
    (化学式・反応式。`$\ce{H2SO4}$` → H₂SO₄、`$\ce{2H2 + O2 -> 2H2O}$` → 矢印付き反応式)。
    数式は**サーバ側**で描画されるので、kit 側の `scripts`(クライアント側)では足せない。
    **Vivify 限定の機能**である点に注意（VS Code の KaTeX は mhchem を読み込まないので、
    `\ce{}` を使った md は配布先で崩れる）。構造式を図として描くほうは
    `:FigOpenStudio rdkit`(SMILES→SVG) が別にある

## 新マシンでの導入
```sh
bash ~/.config/nvim/vivify/install.sh
```
前提: `node`(mise), `ghq`, passwordless sudo(zip 用)。figure studio 用に pip(streamlit / streamlit-ace / schemdraw / matplotlib)も導入。

### ブラウザ起動には wslu 4.x が必須（WSL の地雷）
`config.json` の `browserOptions: { "name": "wslview" }` で既定ブラウザを開く。ところが
**Ubuntu 24.04 の apt 版 wslu(3.2.3) は systemd 版 WSL の binfmt を旧名 `WSLInterop` でしか探さず、
新名 `WSLInterop-late` を認識できないため「WSL Interopability is disabled」でブラウザを開けない**
（`viv`/`vivify-server` は起動するのにタブが出ない、という症状になる）。
→ **PPA の wslu 4.x** を使う（`WSLInterop-late` 対応）:
```sh
sudo add-apt-repository -y ppa:wslutilities/wslu && sudo apt-get update && sudo apt-get install -y wslu
wslview --version   # v4.x なら OK（`grep: ...WSLInterop: No such file` の警告は無害）
```
install.sh に組み込み済み。経緯: howm 日記 `2026-07-13`。

## なぜパッチが要るか（WSL mirrored 限定の地雷）
`networkingMode=mirrored` の WSL2 では**未使用ポートへの接続が ECONNREFUSED を返さずハング**する。
Vivify は起動時 `http.get(localhost:31622/health)` で既存サーバを調べ「error なら自分が listen」する
設計のため、このプローブが固まると起動できない。パッチで 500ms タイムアウト→自前 listen にフォールバック。
（NAT モード/通常 Linux では stock の release でも動くが、パッチ版は両対応。）

## nvim 側
- `lua/vivify.lua` … `,,V` デュアルモード（web=右ペイン / 端末=ブラウザタブ）
- `lua/21_keymap.lua`（`,,V` → `require("vivify").open()`）、`lua/plugins/misc.lua`（vivify.vim spec: `ft=markdown`）
- 追従(スクロール同期)は vivify.vim の autocmd が md 進入時に curl POST する仕組み。
- 図・画像の `Fig*` コマンド群（`,,p`/`,,e`/`,,s`/`,,m`）は **figkit.nvim** へ移動。
  `lua/plugins/misc.lua` の spec で `on_change`(=`vivify.reload`)と
  `open_url`(=web なら右ペイン / 端末ならブラウザタブ)を注入している。

## 経緯
howm 日記: `2026-07-03-1657-chiikawa.md`（Vivify 導入・トラブル全記録）、
`2026-07-06-1049-chiikawa.md`（標準ビューア化・figure studio）。
