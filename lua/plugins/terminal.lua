-- plugins/terminal.lua - ターミナル関連
return {
    -- ターミナル
    {
        "akinsho/toggleterm.nvim",
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