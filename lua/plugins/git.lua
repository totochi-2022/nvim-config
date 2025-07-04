-- plugins/git.lua - Git関連
return {
    -- Git差分表示とHunk操作
    {
        'lewis6991/gitsigns.nvim',
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require('gitsigns').setup({
                signs = {
                    add          = { text = '│' },
                    change       = { text = '│' },
                    delete       = { text = '_' },
                    topdelete    = { text = '‾' },
                    changedelete = { text = '~' },
                    untracked    = { text = '┆' },
                },
                signcolumn = true,
                current_line_blame = false,
                current_line_blame_opts = {
                    virt_text = true,
                    virt_text_pos = 'eol',
                    delay = 1000,
                },
                preview_config = {
                    border = 'rounded',
                    style = 'minimal',
                    relative = 'cursor',
                    row = 0,
                    col = 1
                },
            })
        end
    },

    -- Git操作
    {
        'tpope/vim-fugitive',
        cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gedit", "Gsplit", "Gread", "Gwrite", "Ggrep", "Glog", "Gclog", "Gblame" },
    },

    -- GitHub操作
    {
        'tpope/vim-rhubarb',
        dependencies = 'tpope/vim-fugitive',
        cmd = { "GBrowse" },
    },

    -- Git差分ビューとファイル履歴
    {
        'sindrets/diffview.nvim',
        dependencies = 'nvim-lua/plenary.nvim',
        cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    },
}