vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = "menu,menuone,noinsert"
vim.opt.confirm = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.formatoptions = "jcroqlnt"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.inccommand = "nosplit"
vim.opt.mouse = ""
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 999
vim.opt.shiftround = true
vim.opt.shiftwidth = 4
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.spelllang = { "en" }
vim.opt.splitkeep = "screen"
vim.opt.tabstop = 4
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.updatetime = 200
vim.opt.wildmode = "longest:full,full"
vim.opt.wrap = false

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

vim.api.nvim_create_autocmd({ "WinResized" }, {
    group = vim.api.nvim_create_augroup("EqualizeSplits", { clear = true }),
    callback = function()
        vim.cmd("wincmd =")
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
    {
        "dracula/vim",
        config = function()
            vim.cmd.colorscheme("dracula")
        end,
        init = function()
            vim.opt.termguicolors = true
        end,
        name = "dracula",
        priority = 1000,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            ---@diagnostic disable-next-line; missing-fields
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "c", "lua", "query", "vim", "vimdoc" },
                sync_install = false,
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = true },
            })

            vim.opt.foldmethod = "expr"
            vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
            vim.opt.foldenable = false
        end,
    },
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v3.x",
        init = function()
            vim.g.lsp_zero_extend_cmp = 0
            vim.g.lsp_zero_extend_lspconfig = 0
        end,
        lazy = true,
    },
    {
        "williamboman/mason.nvim",
        config = true,
        lazy = false,
    },
    {
        "hrsh7th/nvim-cmp",
        config = function()
            local lsp_zero = require("lsp-zero")
            lsp_zero.extend_cmp()

            local cmp = require("cmp")
            local cmp_action = lsp_zero.cmp_action()

            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                preselect = "item",
                mapping = {
                    ["<C-y>"] = cmp.mapping.confirm({ select = false }),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<C-p>"] = cmp.mapping(function()
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = "insert" })
                        else
                            cmp.complete()
                        end
                    end),
                    ["<C-n>"] = cmp.mapping(function()
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = "insert" })
                        else
                            cmp.complete()
                        end
                    end),
                    ["<C-f>"] = cmp_action.luasnip_jump_forward(),
                    ["<C-b>"] = cmp_action.luasnip_jump_backward(),
                },
                completion = { completeopt = "menu,menuone,noinsert" },
                formatting = {
                    format = require("lspkind").cmp_format({
                        maxwidth = 50,
                        ellipsis_char = "...",
                    }),
                },
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
            })
        end,
        dependencies = {
            "L3MON4D3/LuaSnip",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "onsails/lspkind.nvim",
            "rafamadriz/friendly-snippets",
            "saadparwaiz1/cmp_luasnip",
        },
        event = "InsertEnter",
    },
    {
        "neovim/nvim-lspconfig",
        cmd = { "LspInfo", "LspInstall", "LspStart" },
        config = function()
            local lsp_zero = require("lsp-zero")
            lsp_zero.extend_lspconfig()

            lsp_zero.on_attach(function(_, bufnr)
                vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr })
                vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, { buffer = bufnr })
                vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, { buffer = bufnr })
                vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr })
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr })
                vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr })
                vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, { buffer = bufnr })
            end)

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "astro",
                    "bashls",
                    "clangd",
                    "cssls",
                    "eslint",
                    "html",
                    "lua_ls",
                    "tailwindcss",
                    "tsserver",
                },
                handlers = {
                    lsp_zero.default_setup,
                    lua_ls = function()
                        local lua_opts = lsp_zero.nvim_lua_ls()
                        require("lspconfig").lua_ls.setup(lua_opts)
                    end,
                },
            })
        end,
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "williamboman/mason-lspconfig.nvim",
        },
        event = { "BufReadPre", "BufNewFile" },
    },
    {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = { { "-", "<CMD>Oil<CR>" } },
        opts = { view_options = { show_hidden = true } },
    },
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<Leader>ff", "<CMD>Telescope find_files<CR>" },
            { "<Leader>fg", "<CMD>Telescope live_grep<CR>" },
        },
        opts = {
            defaults = {
                sorting_strategy = "ascending",
                layout_config = {
                    height = 0.8,
                    prompt_position = "top",
                    width = 0.87,
                    preview_width = 0.5,
                },
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        config = true,
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
        "Exafunction/codeium.vim",
        config = function()
            vim.keymap.set("i", "<M-y>", function()
                return vim.fn["codeium#Accept"]()
            end, { expr = true })
            vim.keymap.set("i", "<M-e>", function()
                return vim.fn["codeium#Clear"]()
            end, { expr = true })
            vim.keymap.set("i", "<M-p>", function()
                return vim.fn["codeium#CycleCompletions"](-1)
            end, { expr = true })
            vim.keymap.set("i", "<M-n>", function()
                return vim.fn["codeium#CycleCompletions"](1)
            end, { expr = true })
        end,
        event = "BufEnter",
    },
    {
        "echasnovski/mini.comment",
        dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
        opts = function()
            require("ts_context_commentstring").setup({ enable_autocmd = false })
            return {
                options = {
                    custom_commentstring = function()
                        return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
                    end,
                },
            }
        end,
    },
}

local opts = {
    defaults = { version = false },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
}

require("lazy").setup(plugins, opts)
