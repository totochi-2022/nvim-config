-- plugins/terminal.lua - ターミナル関連
return {
    -- ターミナル
    {
        "akinsho/toggleterm.nvim",
        cmd = "ToggleTerm",
        keys = { { "<F5>", mode = { "n", "t" } } },  -- F5初回押下まで遅延（open_mappingと同じキー）
        config = function()
            require("toggleterm").setup({
                open_mapping = [[<F5>]],
                start_in_insert = true,
                direction = 'float',
                winbar = {
                    enabled = false,
                    name_formatter = function(term)
                        return term.name
                    end
                },
            })
        end
    },
}