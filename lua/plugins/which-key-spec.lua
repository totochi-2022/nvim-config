-- plugins/which-key-spec.lua - which-keyのキーマップ定義
-- minor_modeで既に定義されているものは除外
return {
  -- リーダーキー 's' - ウィンドウ・バッファ操作（デバッガ関連は除外）
  { "<leader>", group = "ウィンドウ・バッファ操作" },
  { "<leader>b", ":Telescope buffers<CR>", desc = "バッファ一覧" },
  { "<leader>h", ":Telescope frecency<CR>", desc = "最近使用したファイル（頻度順）" },
  { "<leader>H", ":Telescope oldfiles<CR>", desc = "最近使用したファイル（時間順）" },
  { "<leader>r", ":Telescope registers<CR>", desc = "レジスタ一覧" },
  { "<leader>k", ":Telescope keymaps<CR>", desc = "キーマップ一覧" },
  { "<leader>m", ":Telescope marks", desc = "マーク一覧" },
  { "<leader>g", ":Telescope live_grep<CR>", desc = "テキスト検索（Grep）" },
  { "<leader>q", ":Telescope quickfix<CR>", desc = "クイックフィックス一覧" },
  { "<leader>Q", ":Telescope quickfixhistory<CR>", desc = "クイックフィックス履歴" },
  { "<leader>i", ":Telescope ghq list<CR>", desc = "ghqリポジトリ一覧" },
  -- { "<leader>d", ":Telescope diagnostics<CR>", desc = "診断一覧" }, -- minor_modeで定義済み
  { "<leader>f", ":Telescope fd<CR>", desc = "ファイル検索" },
  { "<leader>e", ":Telescope file_browser path=%:p:h<CR>", desc = "ファイルブラウザ（現在のディレクトリ）" },
  { "<leader>J", ":Telescope jumplist<CR>", desc = "ジャンプリスト" },
  { "<leader>S", ":SearchSession<CR>", desc = "セッション検索" },
  { "<leader>u", ":MundoToggle<CR>", desc = "変更履歴（UNDO）表示", mode = "n" },
  { "<leader>t", ":terminal<CR>", desc = "ターミナル起動", mode = "n" },
  { "<leader>o", ":SymbolsOutline<CR>", desc = "アウトライン表示トグル", mode = "n" },
  { "<leader>j", ":<C-u>OpenJunkfile<CR>", desc = "Junkファイルを開く", mode = "n" },
  { "<leader><Space>", "<C-W>p", desc = "前のウィンドウに移動", mode = "n" },
  { "<leader>A", ":Telescope lsp_<Tab>", desc = "LSP機能一覧" },
  { "<leader><F1>", ":Telescope help_tags<CR>", desc = "ヘルプタグ検索" },
  { "<leader><F2>", ":Telescope man_pages<CR>", desc = "マニュアルページ検索" },
  
  -- リーダー + s - Dispモード（ウィンドウ操作）
  { "<leader>s", group = "ウィンドウ操作", mode = { "n", "v" } },
  
  -- リーダー + ? - ヘルプ
  { "<leader>?", group = "ヘルプ" },
  { "<leader>?w", ":WhichKey '<C-w>'<CR>", desc = "ウィンドウ操作のヘルプ", mode = "n" },
  { "<leader>?c", ":WhichKey 'C-'<CR>", desc = "Ctrlキーのヘルプ", mode = "n" },
  { "<leader>?a", ":WhichKey 'M-'<CR>", desc = "Altキーのヘルプ", mode = "n" },
  { "<leader>?", ":WhichKey<CR>", desc = "全キーマップのヘルプ", mode = "n" },

  -- 'm' プレフィックス - LSP・診断関連
  { "m", group = "LSP・診断" },
  { "md", "<cmd>lua vim.lsp.buf.definition()<CR>", desc = "定義にジャンプ", mode = "n" },
  { "mD", "<cmd>lua vim.lsp.buf.declaration()<CR>", desc = "宣言にジャンプ", mode = "n" },
  { "mi", "<cmd>lua vim.lsp.buf.implementation()<CR>", desc = "実装にジャンプ", mode = "n" },
  { "mt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", desc = "型定義にジャンプ", mode = "n" },
  { "mh", "<cmd>lua vim.lsp.buf.signature_help()<CR>", desc = "関数シグネチャ表示", mode = "n" },
  { "mr", "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "リネーム", mode = "n" },
  { "mca", "<cmd>lua vim.lsp.buf.code_action()<CR>", desc = "コードアクション", mode = "n" },
  { "mf", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", desc = "コードフォーマット", mode = "n" },
  { "mrf", "<cmd>lua vim.lsp.buf.references()<CR>", desc = "参照検索", mode = "n" },
  { "me", "<cmd>lua vim.diagnostic.open_float()<CR>", desc = "診断情報を表示", mode = "n" },
  { "mq", "<cmd>lua vim.diagnostic.setloclist()<CR>", desc = "診断をloclistに表示", mode = "n" },
  { "m<Space>", "<cmd>lua vim.lsp.buf.hover()<CR>", desc = "ホバー情報表示", mode = "n" },
  { "ml", ":%s/\\r//g<CR>", desc = "CRを削除（改行コード変換）", mode = "n" },
  { "ml", ":s/\\r//g", desc = "選択範囲のCRを削除", mode = "v" },
  { "mo", ":<C-u>JumpToLine<CR>", desc = "指定行へジャンプ", mode = "n" },
  { "mp", "<Plug>MarkdownPreviewToggle", desc = "Markdownプレビュートグル", mode = "n", remap = true },
  { "mA", "<Plug>(openbrowser-smart-search)", desc = "ブラウザで検索", mode = "n" },
  { "mA", "<Plug>(openbrowser-smart-search)", desc = "選択テキストをブラウザで検索", mode = "x" },
  { "ma", "<Plug>(openbrowser-open)", desc = "ブラウザでURLを開く", mode = "n" },
  { "ma", "<Plug>(openbrowser-open)", desc = "選択URLをブラウザで開く", mode = "x" },
  { "ms", ":ISwapWith<CR>", desc = "引数/要素を交換", mode = "n" },
  { "mS", ":ISwap<CR>", desc = "引数/要素を選択して交換", mode = "n" },
  { "mm", "<Plug>(Marks-toggle)", desc = "マークをトグル", mode = "n" },
  
  -- ワークスペース
  { "mw", group = "ワークスペース" },
  { "mwa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", desc = "ワークスペースフォルダ追加", mode = "n" },
  { "mwr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", desc = "ワークスペースフォルダ削除", mode = "n" },
  { "mwl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", desc = "ワークスペースフォルダ一覧", mode = "n" },
  
  -- 実行
  { "mn", group = "実行" },
  { "mnn", ":Jaq<CR>", desc = "Jaq実行（デフォルト）", mode = "n" },
  { "mnf", ":Jaq float<CR>", desc = "Jaq実行（フロート）", mode = "n" },
  { "mnb", ":Jaq bang<CR>", desc = "Jaq実行（Bang）", mode = "n" },
  { "mnq", ":Jaq quickfix<CR>", desc = "Jaq実行（クイックフィックス）", mode = "n" },
  { "mnt", ":Jaq terminal<CR>", desc = "Jaq実行（ターミナル）", mode = "n" },
  { "mnr", ":QuickRun<CR>", desc = "QuickRun実行", mode = "n" },
  { "mnk", ":call quickrun#session#sweep()<CR>", desc = "QuickRunセッション終了", mode = "n" },
  
  -- 診断ジャンプ
  { "m]", "<cmd>lua vim.diagnostic.goto_next()<CR>zz", desc = "次の診断へ", mode = "n" },
  { "m[", "<cmd>lua vim.diagnostic.goto_prev()<CR>zz", desc = "前の診断へ", mode = "n" },
  { "me]", "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>", desc = "次のエラーへ", mode = "n" },
  { "me[", "<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>", desc = "前のエラーへ", mode = "n" },
  { "mw]", "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.WARN})<CR>", desc = "次の警告へ", mode = "n" },
  { "mw[", "<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.WARN})<CR>", desc = "前の警告へ", mode = "n" },
  { "mi]", "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.INFO})<CR>", desc = "次の情報へ", mode = "n" },
  { "mi[", "<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.INFO})<CR>", desc = "前の情報へ", mode = "n" },
  { "mh]", "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.HINT})<CR>", desc = "次のヒントへ", mode = "n" },
  { "mh[", "<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.HINT})<CR>", desc = "前のヒントへ", mode = "n" },

  -- 'z' プレフィックス - フォールド操作
  { "z", group = "フォールド" },
  { "za", "za", desc = "現在のフォールドをトグル" },
  { "zR", "zR", desc = "すべてのフォールドを開く" },
  { "zM", "zM", desc = "すべてのフォールドを閉じる" },
  { "zr", "zr", desc = "フォールドレベルを1段階開く" },
  { "zm", "zm", desc = "フォールドレベルを1段階閉じる" },
  { "zj", "zj", desc = "次のフォールドへ" },
  { "zk", "zk", desc = "前のフォールドへ" },
  { "zx", "zx", desc = "フォールドを更新して再適用" },
  { "z0", "<cmd>lua SetFoldLevel(0)<CR>", desc = "フォールドレベル0に設定" },
  { "z1", "<cmd>lua SetFoldLevel(1)<CR>", desc = "フォールドレベル1に設定" },
  { "z2", "<cmd>lua SetFoldLevel(2)<CR>", desc = "フォールドレベル2に設定" },
  { "z3", "<cmd>lua SetFoldLevel(3)<CR>", desc = "フォールドレベル3に設定" },
  { "z4", "<cmd>lua SetFoldLevel(4)<CR>", desc = "フォールドレベル4に設定" },

  -- ローカルリーダー（スペース）
  { "<localleader>", group = "ローカル操作" },
  { "<localleader>b", group = "バッファ操作" },
  { "<localleader>c", group = "コメント操作" },
  { "<localleader>v", group = "ウィンドウ分割" },
  { "<localleader>j", group = "領域拡張" },
  { "<localleader>d", ":lua require('dapui').toggle()<CR>", desc = "デバッグUIトグル", mode = "n" },
  { "<localleader>o", ":SymbolsOutline<CR>", desc = "アウトライン表示", mode = "n" },
  { "<localleader>t", ":Translate<CR>", desc = "翻訳", mode = { "n", "x" } },
  
  -- F7 - デバッガ
  { "<F7>", group = "デバッガ", mode = "n" },
  
  -- F8
  { "<F8>", group = "ユーティリティ" },
  { "<F8>E", ":!explorer.exe .<CR>", desc = "エクスプローラでカレントディレクトリを開く", mode = "n" },
  { "<F8>e", ":!tabe<CR>", desc = "新しいタブで開く", mode = "n" },
  { "<F8>x", ":<C-u>TerminalCurrentDir<CR><CR>", desc = "ターミナルでカレントディレクトリを開く", mode = "n" },
  { "<F8>s", ":PackerSync<CR>", desc = "プラグイン同期", mode = "n" },
  { "<F8>c", ":PackerCompile<CR>", desc = "プラグインコンパイル", mode = "n" },
  { "<F8>m", ":Mason<CR>", desc = "Mason（LSP管理）を開く", mode = "n" },
  { "<F8>t", ":TSUpdate<CR>", desc = "Treesitter更新", mode = "n" },
  { "<F8>r", "<cmd>lua RandomScheme()<CR>", desc = "ランダムカラースキーム", mode = "n" },
  
  -- その他
  { "<F3>", ":Telescope command_palette<CR>", desc = "コマンドパレット" },
  { "<F5>", desc = "ターミナルトグル（toggleterm）" },
}