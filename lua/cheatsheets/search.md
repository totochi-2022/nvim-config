# 検索・置換

## カーソル下の単語を検索（asterisk）

| キー | 動作 | 説明 |
|------|------|------|
| `*` | 単語検索（前方） | カーソル位置の単語を検索（カーソル位置維持） |
| `#` | 単語検索（後方） | 逆方向に検索 |
| `g*` | 部分一致検索（前方） | 単語境界を無視した部分一致 |
| `g#` | 部分一致検索（後方） | 逆方向の部分一致 |
| `<LocalLeader>/` | 単語をハイライト検索 | `<Plug>(asterisk-z*)` |
| `n` / `N` | 次/前の検索結果 | 検索結果間を移動 |
| `<C-l>` | ハイライト解除 | `nohlsearch` + 再描画（web再計算も要求） |

## migemo（日本語ローマ字検索） — toggle: m

`<LocalLeader>0` → `m` で migemo をトグル。**ON のとき** `/` `?` `g/` が migemo 検索に置き換わり、ローマ字で日本語を検索できる（flash の画面内ジャンプ `<LocalLeader><Space>` も日本語対応になる）。

| キー | 動作 |
|------|------|
| `/` | migemo 前方検索（migemo ON 時） |
| `?` | migemo 後方検索（migemo ON 時） |
| `g/` | migemo stay 検索（migemo ON 時） |

## ハイライト（quickhl）

| キー | 動作 | 説明 |
|------|------|------|
| `<LocalLeader>x` | 単語をハイライト | カーソル位置の単語（複数色） |
| `<LocalLeader>X` | ハイライトリセット | 全ハイライト解除 |
| `x<LocalLeader>x` | 選択範囲をハイライト | ビジュアル選択 |
| `x<LocalLeader>X` | ハイライトリセット | ビジュアル |

## 検索・置換（grug-far.nvim）

| キー | 動作 | 説明 |
|------|------|------|
| `<Leader>r` | 現在バッファで検索・置換 | `:GrugFarCurrentBuffer` |
| `v<Leader>r` | カーソル下の単語を置換 | `:GrugFarCurrentWord`（ビジュアル） |

## テキスト検索（Telescope）

| キー | 動作 | 説明 |
|------|------|------|
| `<Leader>g` | grep（正規表現） | `:Telescope egrepify` |
| `<Leader>G` | grep（live_grep） | `:Telescope live_grep` |
| `<Leader>f` | ファイル名検索 | `:Telescope fd` |
| `<Leader>h` | 最近のファイル（頻度順） | `:Telescope frecency` |
| `<Leader>H` | 最近のファイル（時間順） | `:Telescope oldfiles` |
| `<Leader>a` | Telescope セレクタ | `:Telescope`（全ピッカー一覧） |

## コマンドライン検索置換

| コマンド | 動作 |
|----------|------|
| `:%s/old/new/g` | バッファ全体を置換 |
| `:'<,'>s/old/new/g` | 選択範囲を置換（`x;` で前置入力） |
| `ml`（n/v） | CR(`\r`)を削除（改行コード変換） |

---
💡 **Tips**:
- 置換のプレビューが欲しいときは `<Leader>r`（grug-far）が便利
- 日本語を探すときは toggle `m`（migemo）を ON にして `/` でローマ字入力
- `<LocalLeader>x` で複数語を別色ハイライトして見比べられる
