-- ============================================
-- MASOUD'S NEOVIM + LAZY.NVIM
-- ============================================

-- Basic settings
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.termguicolors = true

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"

    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath,
    })

    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
        }, true, {})

        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
    -- Colorscheme
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("tokyonight-night")
        end,
    },

    -- Copy yanked text to the host clipboard over SSH
    {
        "ojroques/nvim-osc52",
        config = function()
            local osc52 = require("osc52")

            osc52.setup({
                silent = true,
            })

            local group = vim.api.nvim_create_augroup(
                "Osc52YankToWindows",
                { clear = true }
            )

            -- Automatically copy normal yanks through OSC 52.
            vim.api.nvim_create_autocmd("TextYankPost", {
                group = group,
                callback = function()
                    if vim.v.event.operator == "y" then
                        osc52.copy_register('"')
                    end
                end,
            })

            -- Manual command to copy the unnamed register.
            vim.api.nvim_create_user_command(
                "CopyToWindowsClipboard",
                function()
                    osc52.copy_register('"')
                end,
                { desc = "Copy text to the host clipboard using OSC 52" }
            )
        end,
    },
})
