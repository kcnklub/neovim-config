return {
    {
        "xiyaowong/nvim-transparent",
        config = function()
            require("transparent").setup({
                enable = true,
                extra_groups = {
                    "BufferLineTabClose",
                    "BufferLineBufferSelected",
                    "BufferLineFill",
                    "BufferLineBackground",
                    "BufferLineSeparator",
                    "BufferLineIndicatorSelected",
                },
                exclude = {}
            })
        end
    }
}
