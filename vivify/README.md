# vivify/ — Vivify プレビュー環境の再現用一式

md をレポート化する計画（グラフ/回路図/タイミング図）の閲覧側に Vivify を使う。
本体 `viv`/`vivify-server` はリポ管理外（各マシンでビルド）なので、ここに**再現手順一式**を置く。

## ファイル
- `install.sh` … 上流 clone → パッチ → SEA ビルド → `~/.local/bin` 導入 → config symlink
- `vivify.patch` … 上流への2点パッチ:
  - `src/app.ts`: 起動時 `/health` プローブに 500ms タイムアウト(mirrored 対策)
  - `src/parser/highlight.ts`: 未知言語フェンスの class に元言語名を残す
    (`<pre class="language-wavedrom">` 等。glue が種別検出できるように)
  - `src/parser/markdown.ts`: `import 'katex/contrib/mhchem'` を足して **`\ce{}` を有効化**
    (化学式・反応式。`$\ce{H2SO4}$` → H₂SO₄、`$\ce{2H2 + O2 -> 2H2O}$` → 矢印付き反応式)。
    数式は**サーバ側**で描画されるので `config.json` の `scripts`(クライアント側)では足せない。
    構造式を図として描くほうは `:FigOpenStudio rdkit`(SMILES→SVG) が別にある
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

### 作業サイズ = 出力サイズ（常に 1:1 で描く）
右下パネルの「作業サイズ」がそのまま保存される大きさ。**その大きさの画像に直接注釈を描く**ので、
編集画面がそのまま仕上がりになる（位置も文字の大きさも見たまま）。ズームは純粋な虫眼鏡で、
画像も注釈も同じ比率で拡大されるから何も歪まない。

パネルの「表示 NN%」は編集画面の拡大率。全部が同じ比率で拡大される以上、位置や相対サイズの
判断は狂わないが、**いま実寸を見ているのかどうか**だけは分からない（自動ズームで縮んでいるとき、
実寸では読めない文字を読めると誤判断しがち）。marker.js 側に倍率表示がないのでここに出している。
100% に戻すのは右下の ⊡。
（かつてあった「仕上がり」ボタン＝実際に焼いた PNG のプレビューは、1:1 で描くようになって
画面と同じものになったので撤去した。）

サイズを変えると**エディタごと作り直す**（`targetImage` の差し替えだけでは効かない）。
**描いた注釈は失われない**——state の座標系(`state.width`)と対象画像の大きさが違うとき
marker.js が自動で比率調整する（実測: 360→720 で `left 30→60` / `width 170→340`）。
縮小は毎回**原本から**作るので、サイズを往復しても劣化しない。

縮小の品質: `drawImage` 一発だと縮小率が大きいときに参照する元画素が足りず、モアレや
線の太さのばらつきが出る（実測 2560→360 で、高品質リサンプラ(Pillow LANCZOS)との差が
**8.65 対 6.21**。細い縦線が不揃いになるのが目で見て分かる）。そこで
`createImageBitmap(..., {resizeQuality:'high'})` を使い、無い環境では半分ずつ詰める
段階縮小にフォールバックする（両者は実測で同じ結果になった）。
なお画像ライブラリ側で縮小すればもう一段良い（Pillow のリサンプラは同条件で差 1.6 前後）。

次に開くときの作業サイズは `.ann.json` の `width` が覚えている（marker.js の `AnnotationState` が
キャンバスの大きさを持つので、別途保存しなくてよい）。

**この形に至るまでの経緯**（同じ轍を踏まないように）: 当初は原寸の画像に描いて書き出し時だけ
縮めていた。すると注釈まで一緒に縮んで読めなくなるので state 側で補正 → 編集画面と出力が食い違う →
縮小表示のまま作業すると字が打ちにくく、位置も仕上がりの大きさも分からない、と問題が連鎖した。
**出力と同じ大きさで描く**のが結局いちばん単純で、補正コードも全部要らなくなった。

各ビューアは `img` に `max-width:100%` を掛けるので、カラム幅（Vivify 900px = `static/style.css`、
GitHub 約890px、VSCode はペイン幅）より大きく出しても表示は変わらない。表示まで小さくしたいなら
カラム幅より小さい作業サイズにすること。md に `{width=..}` や `<img>` を書く方法は採らない
（`{width=..}` は Vivify 専用で GitHub/VSCode ではゴミ文字として本文に出る。`<img>` は3つとも効くが、
`vivify.reload()` のキャッシュバスター・`,,e` のパス抽出・リンク差し替えが全て `](..)` 前提なので壊れる）。

### モザイク（自作マーカー）
marker.js のマーカー型は18種あるがぼかし/モザイクは無いので、`MosaicMarker` を自作して
`registerMarkerType` で登録している（上部バーの「▦ モザイク」→ 画像上をドラッグ）。粗さは3段階。

仕組み: **作業サイズの画像全体を一度だけ**モザイク化した data URL を canvas で作り
（縮小 → `imageSmoothingEnabled=false` で拡大）、各マーカーはそれを**元画像と同じ座標**に置いて
矩形でクリップするだけ。`-left/-top` にずらすので、**動かしてもリサイズしても常に真下の領域が出る**
（領域を切り出して貼る方式だと、動かしたとき古い場所の絵が付いてきてしまう）。
state に載るのは矩形の座標だけなので `.ann.json` は膨らまない。
作業サイズを変えるとモザイク画像も作り直す（`mount()` の中）。

**書き出しは自前の `Renderer` で行っている**。marker.js UI 内蔵のラスタライズは自作マーカー型を
知らず、**画面では潰れているのに保存した PNG は素通し**になるため（静かに漏れる事故）。
`renderOnSave=false` にして `editorsave` で `new markerjs3.Renderer()` + `registerMarkerType`
+ `rasterize(state)`。

### 使い方
- `,,e`(:FigEditAuto) … ラスタ画像なら注釈エディタへ（埋込ソース付きなら分割バッファ、draw.io なら draw.io.exe）
- `:FigAnnotateImage` … 判定を飛ばして直接注釈エディタへ
- `:FigClipInfo` … いま `,,p` が何をするかだけ表示（書き込まない）。
  「スクショを撮ったのに SVG が貼られる」＝**クリップボードが更新されていない**ことが多いので、
  その確認用。同じ内容を続けて貼ろうとしたときは `,,p` 自身も警告する
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
- `lua/figure.lua` … 図・画像の「作る/直す」入口。`Fig*` コマンド群と `,,p`/`,,e`/`,,s`/`,,m` の
  振り分け。道具はすべて独立コマンドなので、判定が外れたら直接叩けば回避できる
  (`:Fig<Tab>` で一覧)。実装は diagram.lua と annotate.lua にある。
- `lua/diagram.lua` … 図は **figure studio(左=nvim/右=SVG)** で作成/編集。SVG 固定・ソース埋込で統一。
  補完のためソース部を Ace でなく本物の nvim(ttyd+tmux, pyright)にした。
  - **`,,s`(:FigOpenStudio)**: studio を開く。**カーソル行に既存の `.fig.svg` があればその図**を
    開き、studio 側の `:w` がその図を直接更新する(化学構造式は SMILES 検索が studio にしか
    無いので、開き直せる入口が要る)。図の行でなければ**スクラッチ**で開き、仕上げたら
    ツールバーの **📋 SVGコピー → `,,p`** で md に入れる(draw.io アプリと同じ流儀。
    `assets/` に何も作られないのでボツにしてもゴミが残らない)。
    図の行にいてもスクラッチが欲しいときは `:FigOpenStudio rdkit` のようにテンプレ名を付ける。
  - **`,,m`(:FigNewFromTemplate [schemdraw|matplotlib|rdkit|raw] [svg|png])**: studio を立てず、
    現 md/typst の `assets/` に `<ts>.fig.<fmt>` を作りリンク挿入 → 分割バッファで編集 →
    **`:w`** で再生成。svg が図の主役、png は matplotlib 等の raster 向き。
  - **`,,e`(:FigEditAuto)**: `![](x.svg)` 上で `<metadata id="diagram-source">` があれば埋込ソースを
    分割バッファで復元 → `:w` で上書き。draw.io SVG(`content="<mxfile>"`)→ draw.io.exe。
  - 構成: ttyd(**7690**, tmux セッション `figstudio` で nvim 永続化) / Streamlit(**8501**) / Vivify(**31622**)。
    Streamlit がツールバー+2ペインを描画、左は ttyd iframe、右は Vivify iframe。tmux 永続化で
    ブラウザ/ttyd が落ちても編集状態は残る。同時に1図(固定ポート)。
  - **`,,p`(:FigPasteAuto)**: クリップボードを判定して `assets/` に保存＋リンク挿入。
    Python スニペット(先頭に `import figkit` が要る)→実行して `.fig.svg` / SVG→出所で
    `.fig.svg` か `.drawio.svg` / mxfile→`.drawio` / 画像→`.png`。
    **入力がクリップボードだけ**なので、バッファに「描画済み/未描画」の中間状態ができない
    (以前フェンスを対象にした `:DiagramRender` 方式が分かりにくくなって廃れた理由)。

## 経緯
howm 日記: `2026-07-03-1657-chiikawa.md`（Vivify 導入・トラブル全記録）、
`2026-07-06-1049-chiikawa.md`（標準ビューア化・figure studio）。
