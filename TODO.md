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

## annot（画像注釈）の縮小画質 — 対処済み

- **状態**: **完了**。サーバ(Pillow)縮小で LANCZOS と一致（差 0.00）
- **経緯**: 作業サイズを小さくすると「表示で縮小するより解像度が落ちる」と気付いた。
  canvas の `drawImage` 一発は縮小率が大きいと参照する元画素が足りず、モアレや
  線の太さのばらつきが出る（細い縦線を4倍に拡大すると縞が不揃いなのが目で分かる）
- **実測**（2560→360 の約7倍縮小、Pillow LANCZOS を基準にした RMS 差。小さいほど忠実）:

  | 方法 | 差 |
  |---|---|
  | `drawImage` 一発（修正前） | 8.65 |
  | `createImageBitmap` resizeQuality:'high'（**現在**） | 6.21 |
  | 段階縮小（半分ずつ） | 6.21 |
  | **Pillow のリサンプラ** | **1.6 前後** |

  3倍縮小(900→300)では 6.31 対 5.94 と差は小さい。**縮小率が大きいほど効く**
- **解決**: `/img?p=&w=` が Pillow で縮小して `X-Resize: pillow` を返す。Pillow が無ければ
  原寸＋`X-Resize: none` を返し、ページ側がブラウザ縮小にフォールバックする。
  **stdlib のみで動く性質は維持**（Pillow は「あれば使う」）。PIL を隠したサーバで
  フォールバック側も実測済み

## 図まわりの入口を整理した（2026-09-17 実施済み）

役割を「図の種類」ではなく **編集の仕方** で分け、道具を全部独立コマンドにして、
その上に自動判別を薄く乗せた。**実体は figkit.nvim へ分離した**（下記）。

| キー | コマンド | 動作 |
|---|---|---|
| `,,p` | `:FigPasteAuto` | クリップボードを判定して貼る |
| `,,e` | `:FigEditAuto` | カーソル行を判定して直す |
| `,,s` | `:FigOpenStudio` | Studio を**単体で**開く（作る→📋→`,,p`） |
| `,,m` | `:FigNewFromTemplate` | テンプレから md に直接作る |

個別コマンド: `:FigRenderPython` / `:FigPasteSvg` / `:FigPasteDrawioXml` / `:FigPasteImage` /
`:FigEditSource` / `:FigAnnotateImage` / `:FigOpenDrawioApp`（判定が外れたとき直接叩ける）

### 設計の要点（忘れると同じ道を通る）
- **入力はクリップボードだけ**。以前「md のフェンスにカーソルを置いて `:DiagramRender`」という
  方式があったが、バッファに「描画済み/未描画」の中間状態ができて分からなくなり廃止された。
  クリップボード入力なら中間状態が無く、貼った時点で常に「ファイル+リンク」の1状態
- **Studio は draw.io と同じ位置づけ**（単体で開く外部ツール、出力はクリップボード）。
  `assets/` に何も書かないので**ボツにしてもゴミが残らない**
- **Python の実行には `import figkit` が要る**。誤爆防止であってセキュリティではない
  （ローカルで exec する以上、完全な防御は無理）。印はソースに残って SVG に埋め込まれるので、
  studio から 📋 コピーして `,,p` しても通る
- `render_schemdraw.py` 側は `sys.modules.setdefault("figkit", ...)` でスタブを登録。
  ゲートは `,,p` にだけ置き、`,,e` → `:w` の再生成には要求しない（自分で開いたファイルなので）

### 採らなかった案と理由
- **フェンス(wavedrom/chart/kvlist)を studio に寄せる**: ソースが md 本文にあるから grep も
  git diff も効く。SVG の `<metadata>` に入れると **diff が読めなくなる**
- **annot を Streamlit で包む**: annot は既に全画面の workbench。iframe が増えて表示が小さくなるだけ
- **ビューア側で編集して書き戻す**: 貼り忘れ・二重編集で正本がずれる。編集を nvim に残せば発生しない
- **Python フェンスのリアルタイム描画**: md を開いただけで任意コードが走る。今は「自分で開いて
  自分で `:w` したときだけ」実行されるので、その性質を壊さない

### 残り
- Studio 自体は残した（「試行錯誤する場所」として使い心地が良いため）。`,,s` はカーソル行に
  図があればその図を開く。**SMILES 検索の置き場**だけが studio 固有なので、将来 Streamlit を
  畳むならそこをどうするか（化学構造式は studio でないと編集がしんどい、というのが実感）
- draw.io を web 版(embed モード)にして preview ペインに入れる案。`?embed=1&proto=json` +
  postMessage、`format:'xmlsvg'` が今の `.drawio.svg` と同形式。書き戻しは annot と同じ仕組みが使える
- **単一図ライブビューア**（その図だけ大きく表示）。フェンス系は `vivify.vim` が `TextChanged` で
  push しているので**既に打鍵ごとにリアルタイム**。足りないのは「その図だけ大きく」だけ

## 図・画像ツールを figkit.nvim に分離した（2026-09-18 実施済み）

`lua/figure.lua` + `diagram.lua` + `annotate.lua` + `vivify/{render,annot}/` を
[totochi-2022/figkit.nvim](https://github.com/totochi-2022/figkit.nvim)（`~/work/figkit.nvim`）へ。
このページの図まわりの記述（`,,p`/`,,e`/`,,s`/`,,m`・annot の縮小画質・設計メモ）は
**そのプラグインの話**として読むこと。`lua/wslpath.lua` だけは nvim-config 側でも
4箇所使っているので両方に置いてある。

繋ぎは2つのフックだけ:
- `on_change(buf)` … 図/注釈を書いたあと `require('vivify').reload(buf)`
- `open_url(url, title)` … web=右プレビューペイン / 端末=`wslview`

spec は `lua/plugins/misc.lua`（`dev = true` → `~/work/figkit.nvim`、無いマシンは GitHub から clone）。
**古い annot サーバ(31624)が生きているとファイルが消えた旧パスを掴んだままになる**ので、
分離直後は一度落とす（今回 404 を踏んだ）。

自作部分のライセンスは未定。marker.js 3 は **linkware**（ロゴ表示を残す条件）なので、
figkit 側 README に明記してある。

## 今後のタスク
- [ ] x/X のundo履歴統合の別解決策を調査
- [ ] トグル機能の window-local オプション対応改善
- [ ] 診断表示モードの改善
- [x] annot の縮小を Pillow 経由にする（stdlib 限定は維持したまま）
- [ ] mhchem(`\ce{}`) のデモを md-preview-kit の sample.md 側へ移す
      （`vivify/sample.md` は kit へ分離済み。退避: 下記セクション参照）
      ※ ただし **VS Code の KaTeX は mhchem を読まない**ので、配布先で崩れる。
        kit に入れるなら「Vivify 限定」と明記するか、入れない判断もある
- [x] 図まわりの入口整理（`Fig*` コマンド群 + `,,p`/`,,e`/`,,s`/`,,m`）
- [x] 図・画像ツールを figkit.nvim として独立させる
- [ ] figkit.nvim 自作部分のライセンスを決める（`LICENSE` を置く）
- [ ] 単一図ライブビューア（`glue.js` 再利用・編集は nvim のまま）
- [ ] draw.io を web 版(embed モード)で preview ペインに埋め込む
- [ ] SMILES 検索の置き場（Streamlit を畳むなら必要。畳まない判断もあり）
- [ ] LSPホバーの「No information available」メッセージ抑制
  - vim.lsp.handlers["textDocument/hover"]のオーバーライドを試したが動作せず
  - ハンドラー設定タイミングやLSP初期化順序の調査が必要
  - 代替案：カスタム:Messagesコマンドでフィルタリング表示