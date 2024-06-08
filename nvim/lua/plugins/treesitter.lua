return {{
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        local config = require("nvim-treesitter.configs")
        config.setup({
            ensure_installed = {"lua", "terraform", "go"},
            highlight = {
                enable = true
            },
            indent = {
                enable = true
            },
            auto_install = true,
            sync_install = false
        })
    end
}}

