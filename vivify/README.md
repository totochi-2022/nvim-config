# vivify/ — Vivify プレビュー環境の再現用一式

md をレポート化する計画（グラフ/回路図/タイミング図）の閲覧側に Vivify を使う。
本体 `viv`/`vivify-server` はリポ管理外（各マシンでビルド）なので、ここに**再現手順一式**を置く。

## ファイル
- `install.sh` … 上流 clone → パッチ → SEA ビルド → `~/.local/bin` 導入 → config symlink
- `vivify.patch` … 上流への2点パッチ:
  - `src/app.ts`: 起動時 `/health` プローブに 500ms タイムアウト(mirrored 対策)
  - `src/parser/highlight.ts`: 未知言語フェンスの class に元言語名を残す
    (`<pre class="language-wavedrom">` 等。glue が種別検出できるように)
- `config.json` … Vivify 設定(browserOptions/timeout/scripts)。`~/.config/vivify/config.json` はこれへの symlink
- `scripts/` … `config.json` の `scripts` で読み込む描画グルー一式:
  - `wavedrom.min.js` + `wavedrom-skin-default.js`(vendored)
  - `chart.umd.js`(vendored)
  - `glue.js` … `pre.language-wavedrom`/`pre.language-chart` を WaveDrom/Chart で描画。
    `MutationObserver` で ws 更新にも追従
  - `ladder.glue.js` … `pre.language-kvlist`(KVニーモニック)をラダー図SVGに描画＋
    ホバーで同一デバイスをクロスリファレンスハイライト。**生成物・git管理外**。
    lazy の `totochi-2022/ladder_viewer` (plugins/misc.lua) の build フックが
    `vivify-glue.sh` で生成する(`:Lazy update` / `:Lazy build ladder_viewer` で再生成＋
    vivify-server kill、次の `,,V` で反映)。dev モードにつき `~/work/ladder_viewer` が
    あればそれがソース、無いマシンでは GitHub から clone される
- `render/render_schemdraw.py` … Python スニペット→画像化。namespace に `out`(出力パス)を渡し、
  ソースが `out` に保存すれば何でも可。**出力拡張子で形式判定(svg/png/jpg)**。元ソースを埋込:
  SVG=`<metadata>` / PNG=tEXt チャンク / JPEG=COM コメント(draw.io 方式 round-trip)。
  `--extract <file>` で埋込ソースを取り出す(svg/png/jpg 共通・`,,e` の判別に使用)。png/jpg は Pillow 使用。
- `render/studio.py` … Streamlit 製 figure studio。**左=vim(ttyd の nvim)/右=ライブSVG(白ボックス)**、
  上部ツールバー(テンプレ挿入/📋SVGコピー)。`?svg=&py=&ttyd=&sock=` を受け取り、左に ttyd(nvim)を
  iframe で、右は `st.fragment(run_every="1s")` で SVG を読み直して表示(`:w` で更新・端末は再描画しない)。
  生成エラー時(=`<py>.err` が在る)は画像も📋コピーも出さずエラーだけ表示(古い画像を残さない)。
  テンプレ挿入は `?py=` を書き換え **nvim RPC(`--remote-expr 'execute("edit! | write")'`)** でリロード
  (tmux send-keys は noice の cmdline ポップアップにキーを取りこぼすため不可)。
- `sample.md` … 動作確認用デモ（`,,V` で開く）

## annot/ — 画像に注釈を付ける（marker.js 3）

スクショ等の**既にある画像**に矢印/枠/黒塗り/コールアウトを重ねる。figure studio が
「Python ソース → 図」なのに対し、こちらは「画像 → 注釈」担当。依存は stdlib のみ（Streamlit 不要）。

- `server.py` … 127.0.0.1:**31624** の小さな HTTP サーバ。`annotate.lua` が jobstart で起こす。
  `/annot`(エディタ) `/img`(画像配信) `/state`(state 取得) `/save`(書き出し)。
  画像を**同一オリジンで配信する**のが要点＝canvas が汚染されず `toDataURL` が通る。
- `editor.html` … marker.js UI の `AnnotationEditor` を貼るだけのページ。`editorsave` を
  `POST /save` に流す。合成は原寸で出す(`rendererSettings.naturalSize`)。
- `vendor/` … `markerjs3.umd.js`(グローバル `markerjs3`) + `markerjs-ui.umd.js`(`markerjsUI`)。
  **読み込み順が固定**(UI が markerjs3 のグローバルを参照)。
  ライセンス: marker.js 3 は **linkware**(商用含め無料・編集中にロゴ表示を残す条件、`vendor/LICENSE.markerjs3.txt`)、
  marker.js UI は MIT。

### 保存モデル（原本非破壊・可逆）
```
assets/<ts>.png        原本。img-clip が置いたまま。**書き換えない**
assets/<ts>.ann.json   marker.js の AnnotationState。注釈の正本(git で差分が読める)
assets/<ts>.ann.png    合成結果。md はこれを参照する(生成物・持ち出し用)
```
保存すると `server.py` が2ファイルを書き、起動元 nvim の socket へ `--remote-expr` で
`annotate.on_saved()` を叩く → md のリンクを `.ann.png` に差し替え + `vivify.reload()`
（studio.py と同じ手口。バッファを書き換えるだけで `:w` はしない＝`,,p` と同じ流儀）。

### 書き出しサイズ（表示倍率とは独立）
右下パネルの「書き出し」欄が保存される幅。**ズーム（`− / ⊡ / +`）は表示だけを変え、保存サイズには
触らない**。幅を打ち込んでも表示倍率は動かさない（編集中の見え方を勝手に変えない）。

仕上がりの確認は「仕上がり」ボタン。**ズームで縮小して見せる方式は嘘になるので採らない**——
注釈サイズの補正は書き出し時の state 側にしか掛かっておらず、編集中のマーカーには効かないので、
縮小表示すると注釈だけ出力より小さく見えてしまう。ボタンは保存と同じ経路で実際に PNG を焼き、
それを原寸で重ねて出す（クリック / Esc で閉じる）。

当初は「表示倍率＝書き出しサイズ」にしていたが、小さく出したいときに縮小表示のまま作業することに
なり**文字が打ちにくかった**ので分離した。今は「幅を打つ → 仕上がりが一度表示される → `+` で
表示を戻して普通に編集 → 保存されるのは指定した幅」という流れになる。

各ビューアは `img` に `max-width:100%` を掛けるので、**カラム幅より大きく出しても表示は変わらない**
（Vivify 900px = `static/style.css`、GitHub 約890px、VSCode はペイン幅）。表示まで小さくしたいなら
カラム幅より小さく出すこと。これなら md に `{width=..}` や `<img>` を書かずに全ビューアで効く
（`{width=..}` は Vivify 専用で GitHub/VSCode ではゴミ文字として本文に出る。`<img>` は3つとも効くが、
`vivify.reload()` のキャッシュバスター・`,,e` のパス抽出・リンク差し替えが全て `](..)` 前提なので壊れる）。

state は**原本の座標系**で保存されるので解像度非依存。`MAX_WIDTH` を変えて保存し直せば、
同じ注釈のまま何度でも別サイズに焼き直せる（720 → 1600 で確認済み）。
元から `MAX_WIDTH` より小さい画像は拡大しない。

### 縮小して書き出すときの注釈サイズ補正
文字サイズ・線幅は「画像の座標系」で持つので、縮小して書き出すと注釈まで一緒に縮んで読めなくなる。
**書き出し直前に state のコピー側で `fontSize` と `strokeWidth` を 1/倍率 倍する**ことで、
出力での絶対サイズが原寸のときと揃う（50% 書き出しでも文字の外接矩形は 29×12px で原寸と一致）。

**編集中のマーカーを直接いじってはいけない**。marker.js UI は*新しいマーカーを作るたびに既存
マーカーのスタイルを既定値へ書き戻す*ため、ライブに当てた補正は2個目を足した時点で消える
（実測: 50% で Frame を作ると既存 Text の fontSize が 2→1、Frame の strokeWidth が 6→3 に戻る）。
state は書き出し直前のコピーなので誰にも上書きされない。

副作用として、縮小表示中は画面の注釈が出力より小さく見える（出力では原寸相当で焼かれる）。
そのため仕上がり確認は表示倍率ではなく「仕上がり」ボタン（実際に焼いた PNG）で行う。

### モザイク（自作マーカー）
marker.js のマーカー型は18種あるがぼかし/モザイクは無いので、`MosaicMarker` を自作して
`registerMarkerType` で登録している（上部バーの「▦ モザイク」→ 画像上をドラッグ）。粗さは3段階。

仕組み: 読み込み時に**画像全体を一度だけ**モザイク化した data URL を canvas で作り
（縮小 → `imageSmoothingEnabled=false` で拡大）、各マーカーはそれを**原本と同じ座標**に置いて
矩形でクリップするだけ。`-left/-top` にずらすので、**動かしてもリサイズしても常に真下の領域が出る**
（領域を切り出して貼る方式だと、動かしたとき古い場所の絵が付いてきてしまう）。
state に載るのは矩形の座標だけなので `.ann.json` は膨らまず、解像度非依存のまま。

**書き出しは自前の `Renderer` で行っている**。marker.js UI 内蔵のラスタライズは自作マーカー型を
知らず、モザイクが焼かれないため（`renderOnSave=false` にして `editorsave` で
`new markerjs3.Renderer()` + `registerMarkerType` + `rasterize(state)`）。

### 使い方
- `,,e`(OpenDrawio) … ラスタ画像なら注釈エディタへ（svg は従来どおり studio/draw.io）
- `:Annot [path]` … 引数省略でカーソル行の画像リンク
- `.ann.png` に対して `,,e` すると**原本 + state に解決して再開**する。原本が消えている場合は
  「焼き込み済みへの重ね描き」を避けて中断する。
- nvim 側は `lua/annotate.lua`。

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
- `lua/diagram.lua` … 図は **figure studio(左=nvim/右=SVG)** で作成/編集。SVG 固定・ソース埋込で統一。
  補完のためソース部を Ace でなく本物の nvim(ttyd+tmux, pyright)にした。
  - **`:Studio [schemdraw|matplotlib|raw] [svg|png]`**: 現 md/typst の `assets/` に `<ts>.fig.<fmt>` を
    作りリンク挿入(既定 svg) → temp `.py` を作り studio を開く。左=nvim で編集 → **`:w`** で再生成
    (BufWritePost)→ 右が更新。svg が図の主役、png は matplotlib 等の raster 向き。
  - **`,,e`(OpenDrawio)**: `![](x.svg)` 上で `<metadata id="diagram-source">` があれば埋込ソースを復元して
    studio で編集 → `:w` で上書き。draw.io SVG(`content="<mxfile>"`)→ draw.io.exe。
  - 構成: ttyd(**7690**, tmux セッション `figstudio` で nvim 永続化) / Streamlit(**8501**) / Vivify(**31622**)。
    Streamlit がツールバー+2ペインを描画、左は ttyd iframe、右は Vivify iframe。tmux 永続化で
    ブラウザ/ttyd が落ちても編集状態は残る。同時に1図(固定ポート)。
  - **`,,p`(SmartPaste)**: クリップボードの SVG/draw.io を保存＋`![]`挿入（外部からの貼付用）。

## 経緯
howm 日記: `2026-07-03-1657-chiikawa.md`（Vivify 導入・トラブル全記録）、
`2026-07-06-1049-chiikawa.md`（標準ビューア化・figure studio）。
