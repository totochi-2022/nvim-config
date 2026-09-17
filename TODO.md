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

## annot（画像注釈）の縮小画質

- **状態**: 一段目は対処済み（`b471752`）。もう一段上げられる余地が残っている
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
- **残件**: サーバ側（`vivify/annot/server.py` の `/img`）で Pillow を使って縮小すれば
  1.6 前後まで届く。いまサーバは **stdlib のみ**で動いているのが取り柄なので、
  「Pillow があれば使い、無ければ今のブラウザ側縮小にフォールバック」にするのが落とし所。
  Pillow 自体は figure studio 用に `install.sh` で導入済み＝実機には存在する
- **優先度**: 低（現状でも実用上は十分マシになっている）

## 図まわりの入口を整理する（検討メモ）

### いま何が起きているか
`,,e` の行き先が3つに分岐していて、役割分担が**設計ではなく経緯**で決まっている。

| 操作 | 行き先 | プロセス |
|---|---|---|
| `:Studio [schemdraw\|rdkit\|matplotlib\|raw]` | Streamlit studio（新規作成のみ） | Streamlit + ttyd + tmux（7690 / 8501） |
| `,,e`（埋込ソース付き svg/png/jpg） | `edit_source`＝分割バッファ | 0 |
| `,,e`（ラスタ画像） | annot（preview ペイン） | stdlib サーバ1つ（31624） |
| `,,e`（draw.io の svg） | `draw.io.exe` | Windows アプリ |

元は `,,e` も studio を開いていたが、`295acc4`（軽量ソース編集 `:FigEdit` の追加）で
「ちょっと直すのに Streamlit が立つのは重い」という理由で分岐した。筋を通した分割ではない。

**欠けているもの**: `:Studio` は**常に新規作成**なので、既存の図を studio で開き直す入口が無い。
だから全部軽い方へ流れ、分岐が恣意的に見える。

### 整理の方針（案）
役割を「図の種類」ではなく **編集の仕方** で分ける:

> **`,,e` = ソースを手で直す** ／ **`:Studio` = 見ながら調整する**

1. **`:Studio` を引数なしで実行したらカーソル行の対象を開く**（小）
   - Python 図 → 既存の studio / ラスタ画像 → annot
   - これだけで「入口が揃っていない」問題が消える
2. **単一図ライブビューア**（中）
   - 「その図だけを大きくライブ表示する」ペイン。描画は `glue.js` をそのまま読めば
     **md preview と完全に同じ絵**になる（`pre.language-<kind>` の DOM を作って渡すだけ）
   - **編集は nvim のままにする**のが要点。書き戻しもテキストエリアも不要になり、
     「md と studio のどちらが正本か」問題が生じない。pyright 補完も md の diff も維持
   - フェンス系は `vivify.vim` が `TextChanged,TextChangedI` で push しているので
     **既に打鍵ごとにリアルタイム追従**している（`:w` すら不要）。Python 図だけ `:w`
3. それで足りるなら **studio を退役**（Streamlit / ttyd / tmux とポート2つが消える）

### 採らないと判断したもの
- **フェンス（wavedrom/chart/kvlist）を studio に寄せる**: ソースが md 本文にあるから
  grep も git diff も効く。SVG の `<metadata>` に入れると **diff が読めなくなる**
- **annot を Streamlit で包む**: annot は既に全画面の workbench。iframe が1枚増えて
  表示が小さくなり、プロセスも増えるだけ
- **ビューア側で編集して書き戻す**: 貼り忘れ・二重編集で正本がずれる。編集を nvim に
  残せばこの問題自体が発生しない

### 付随: ドキュメントが実体とずれている
`vivify/sample.md` の「3c. 回路図」が **`:DiagramRender` / `:DiagramEdit`** を説明しているが、
**このコマンドは現在のコードに存在しない**（grep で sample.md にしかヒットしない）。
今は `:Studio` と `:FigEdit` / `,,e`。sample.md を見て打っても無いので、まずここを直す。

## 今後のタスク
- [ ] x/X のundo履歴統合の別解決策を調査
- [ ] トグル機能の window-local オプション対応改善
- [ ] 診断表示モードの改善
- [ ] annot の縮小を Pillow 経由にする（上記セクション参照。stdlib 限定を崩すかの判断込み）
- [ ] `vivify/sample.md` 3c の `:DiagramRender`/`:DiagramEdit` を現状（`:Studio`/`,,e`）に直す
- [ ] `:Studio` を引数なしでカーソル行の既存図に対して使えるようにする
- [ ] 単一図ライブビューア（`glue.js` 再利用・編集は nvim のまま）を試作し、studio 退役を判断
- [ ] LSPホバーの「No information available」メッセージ抑制
  - vim.lsp.handlers["textDocument/hover"]のオーバーライドを試したが動作せず
  - ハンドラー設定タイミングやLSP初期化順序の調査が必要
  - 代替案：カスタム:Messagesコマンドでフィルタリング表示