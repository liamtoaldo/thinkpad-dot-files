-- ========================================================================== --
-- SETTINGS
-- ========================================================================== --
vim.g.mapleader = " "
vim.opt.background = "dark"
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"

-- Status column: fold arrows + line numbers (click to toggle folds)
_G.my_smart_stc = function()
	local win = vim.g.statusline_winid
	local buf = vim.api.nvim_win_get_buf(win)
	local ft = vim.bo[buf].filetype

	if ft == "NvimTree" then
		return "%s"
	end

	local lnum = vim.v.lnum
	local icon = " "
	if vim.fn.foldclosed(lnum) == lnum then
		icon = "▶"
	elseif vim.fn.foldlevel(lnum) > 0 and vim.fn.foldlevel(lnum) > vim.fn.foldlevel(lnum - 1) then
		icon = "▼"
	end

	return "%s%=%l %@v:lua.my_fold_click@" .. icon .. "%*  "
end

_G.my_fold_click = function()
	local mouse = vim.fn.getmousepos()
	if mouse and mouse.line > 0 then
		if vim.fn.foldclosed(mouse.line) ~= -1 then
			pcall(vim.cmd, mouse.line .. "foldopen")
		else
			pcall(vim.cmd, mouse.line .. "foldclose")
		end
	end
end

vim.opt.statuscolumn = "%!v:lua.my_smart_stc()"

-- Requires `pip install pynvim`
vim.g.python3_host_prog = '/usr/bin/python3' 


-- ========================================================================== --
-- PLUGINS (Lazy.nvim)
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- Theme (Nord)
	{ 
		"shaunsingh/nord.nvim", 
		lazy = false, 
		priority = 1000, 
		config = function() 
			vim.cmd.colorscheme("nord") 
		end 
	},

	-- Noice (modern cmdline + notifications)
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				inc_rename = false,
				lsp_doc_border = true,
			},
			routes = {
				{
					filter = { event = "msg_show", min_height = 2 },
					view = "mini",
				},
			}
		}
	},
	{ "stevearc/dressing.nvim", event = "VeryLazy" },

	-- Cursor trail animation
	{
		"sphamba/smear-cursor.nvim",
		opts = {
			stiffness = 0.7,
			trailing_stiffness = 0.6,
			damping = 0.85,
			cursor_color = "#81A1C1",
		}
	},

	-- Statusline + bufferline
	{ "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = { options = { theme = 'nord' } } },
	{ "akinsho/bufferline.nvim", version = "*", dependencies = "nvim-tree/nvim-web-devicons", opts = {} },

	-- File explorer
	{ "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = { view = { width = 30 } } },

	-- Treesitter
	{ 
		"nvim-treesitter/nvim-treesitter", 
		build = ":TSUpdate",
		config = function()
			local status_ok, treesitter = pcall(require, "nvim-treesitter.configs")
			if not status_ok then
				return
			end

			treesitter.setup({
				ensure_installed = { "c", "lua", "python", "go", "javascript", "bash", "vimdoc" },
				highlight = { enable = true },
			})
		end
	},

	-- Telescope
	{ 
		"nvim-telescope/telescope.nvim", 
		dependencies = { "nvim-lua/plenary.nvim" } 
	},

	-- Find and replace
	{
		"nvim-pack/nvim-spectre",
		dependencies = { "nvim-lua/plenary.nvim" }
	},

	-- Terminal
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		opts = {
			size = 15,
			open_mapping = [[<C-t>]],
			direction = "horizontal",
			close_on_exit = true,
			hide_numbers = true,
		}
	},

	-- LSP
	{ "williamboman/mason.nvim" },
	{ "williamboman/mason-lspconfig.nvim" },
	{ "neovim/nvim-lspconfig" },

	-- Misc plugins
	{ "wakatime/vim-wakatime", lazy=false },
	{ "christoomey/vim-system-copy" },
	{ "tpope/vim-surround" },
	{ "numToStr/Comment.nvim", opts = {} },
	{ "windwp/nvim-autopairs", opts = {} },
	{ "ap/vim-css-color" },
	{
		"CRAG666/code_runner.nvim",
		opts = {
			filetype = {
				kotlin = "kotlinc $fileName -include-runtime -d $fileNameWithoutExt.jar && java -jar $fileNameWithoutExt.jar",
				python = "python3 -u",
				go = "go run",
				c = "gcc $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt",
				cpp = "g++ $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt",
				javascript = "node",
				sh = "bash",
			},
		},
	},
	{ "hugolgst/vimsence" },

	-- ======================================================================== --
	-- LSP + Autocompletion
	-- ======================================================================== --
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
		},
		config = function()
			-- Diagnostic signs
			local signs = { Error = "✘", Warn = "▲", Hint = "⚑", Info = "»" }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
			end
			vim.diagnostic.config({
				virtual_text = { prefix = "●" },
				signs = true,
				update_in_insert = false,
				float = { border = "rounded" },
			})

			-- Mason
			require("mason").setup({ ui = { border = "rounded" } })
			require("mason-lspconfig").setup({
				ensure_installed = { "gopls", "pyright", "clangd" },
			})


			-- Completion
			local cmp = require("cmp")
			cmp.setup({
				snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					['<CR>'] = cmp.mapping.confirm({ select = true }),

					['<C-n>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end, { "i", "s" }),

					['<C-p>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "i", "s" }),

					['<C-Space>'] = cmp.mapping.complete(),
				}),
				sources = { { name = 'nvim_lsp' } }
			})

			-- Server startup (Neovim 0.11+ compatible)
			require("lspconfig")
			local capabilities = require('cmp_nvim_lsp').default_capabilities()
			-- clangd disabled for networking exam, re-enable later
			local servers = { "gopls", "pyright", "clangd" }

			for _, lsp in ipairs(servers) do
				if vim.fn.has("nvim-0.11") == 1 then
					vim.lsp.config[lsp] = vim.tbl_deep_extend("force", vim.lsp.config[lsp] or {}, {
						capabilities = capabilities,
					})
					vim.lsp.enable(lsp)
				else
					require("lspconfig")[lsp].setup({ capabilities = capabilities })
				end
			end
		end
	},

	-- Git diff
	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			file_panel = {
				win_config = {
					position = "left",
					width = 30,
				},
			},
		}
	},

	-- Indent guides (static)
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = { 
				char = "│", 
				tab_char = "│"
			},
			scope = { enabled = false },
		}
	},

	-- Scope highlight (dynamic)
	{
		"echasnovski/mini.indentscope",
		version = false,
		config = function()
			vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#88C0D0", nocombine = true })

			require("mini.indentscope").setup({
				symbol = "│",
				options = {
					border = "both",
					try_as_border = true,
				},
				draw = {
					delay = 0,
					animation = function() return 0 end,
				},
			})
		end
	},

	-- Dashboard
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			dashboard = { 
				enabled = true,
			},
		},
	},

	-- Code folding (UFO)
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		config = function()
			vim.o.foldcolumn = '1'
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = "Open all folds" })
			vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = "Close all folds" })

			require('ufo').setup({
				provider_selector = function(bufnr, filetype, buftype)
					return {'treesitter', 'indent'}
				end
			})
		end
	},

	-- GitHub Copilot
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = { 
					enabled = true, 
					auto_trigger = true, 
					keymap = { accept = "<C-j>" }
				},
				filetypes = {
					yaml = true,
					markdown = true,
					help = true,
					gitcommit = true,
					gitrebase = true,
					hgcommit = true,
					svn = true,
					cvs = false,
					["."] = true,
				},
				panel = { enabled = false },
			})
		end,
	},
})

-- ========================================================================== --
-- Diffview colors (Nord palette)
-- ========================================================================== --
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#3B4252", default = false })
		vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#4C566A", fg = "#4C566A", default = false })
		vim.api.nvim_set_hl(0, "DiffChange", { bg = "#2E3440", default = false })
		vim.api.nvim_set_hl(0, "DiffText", { bg = "#434C5E", default = false })
	end,
})

-- ========================================================================== --
-- KEYBINDINGS
-- ========================================================================== --
local map = vim.keymap.set

-- Scrolling
map('n', 'K', '<C-u>')
map('n', 'J', '<C-d>')
map('v', 'K', '<C-u>')
map('v', 'J', '<C-d>')
map('n', '<C-U>', '{')
map('n', '<C-D>', '}')

-- Save
map({'n', 'v', 'i'}, '<C-S>', '<cmd>update<cr><esc>')

-- Jump to mark
map('n', "'", '`')

-- Split navigation
map('n', '<C-J>', '<C-W><C-J>')
map('n', '<C-K>', '<C-W><C-K>')
map('n', '<C-L>', '<C-W><C-L>')
map('n', '<C-H>', '<C-W><C-H>')

-- Buffer navigation
map('n', '<C-N>', ':bnext<CR>')
map('n', '<C-P>', ':bprev<CR>')

-- Split resize
map('n', '<C-.>', '<cmd>resize +2<CR>')
map('n', '<C-,>', '<cmd>resize -2<CR>')
map('n', '<C-ò>', '<cmd>vertical resize +2<CR>')
map('n', '<C-m>', '<cmd>vertical resize -2<CR>')


-- Function keys
map('n', '<F5>', '<cmd>RunCode<CR>', {noremap = true, silent = true})
map('n', '<leader>e', ':NvimTreeToggle<CR>') 

-- Move lines
map('n', '<C-Up>', ':m -2<CR>')
map('n', '<C-Down>', ':m +1<CR>')

-- Blackhole register (x and c don't overwrite clipboard)
map('n', 'x', '"_x')
map('n', 'X', '"_X')
map('n', 'c', '"_c')
map('n', 'C', '"_C')
map('x', 'p', '"_dP')

-- Groff + Zathura
map('n', 'q', ':q<CR>')
map('n', '<F12>', ':update<bar> :execute "! groff -ms % -T pdf >> %.pdf -k -U -t -e"<CR><CR>')
map('n', '<F11>', ':execute "! zathura %.pdf"<CR><CR>')


-- ========================================================================== --
-- VS Code-style keybindings
-- ========================================================================== --

-- Ctrl+P: find files
map('n', '<C-p>', '<cmd>Telescope find_files<CR>')

-- Ctrl+F: live grep
map('n', '<C-f>', '<cmd>Telescope live_grep<CR>')

-- Find files (include ignored)
vim.keymap.set('n', '<C-M-p>', function()
  require('telescope.builtin').find_files({ 
    no_ignore = true, 
    hidden = true 
  })
end, { desc = "Find files (include ignored)" })

-- Grep (include ignored)
vim.keymap.set('n', '<C-M-f>', function()
  require('telescope.builtin').live_grep({
    additional_args = function(args)
      return vim.list_extend(args, { "--hidden", "--no-ignore" })
    end,
  })
end, { desc = "Grep (include ignored)" })

-- Tab switching
map('n', '<C-Tab>', '<cmd>BufferLineCycleNext<CR>')
map('n', '<C-S-Tab>', '<cmd>BufferLineCyclePrev<CR>')

-- Toggle comment (Ctrl+/ sends Ctrl+_ in terminals)
map('n', '<C-_>', 'gcc', { remap = true })
map('v', '<C-_>', 'gc', { remap = true })

-- Close buffer
map('n', '<C-x>', '<cmd>bd<CR>')

-- Double Esc to exit terminal mode
map('t', '<Esc><Esc>', [[<C-\><C-n>]])

-- Toggle git sidebar
map('n', '<leader>g', function()
	local ok, lib = pcall(require, 'diffview.lib')
	if ok and lib.get_current_view() then
		vim.cmd('DiffviewClose')
	else
		vim.cmd('DiffviewOpen')
	end
end, { desc = "Toggle Git Sidebar" })

-- Find and replace
map('n', '<leader>h', '<cmd>lua require("spectre").toggle()<CR>')

-- Move tab left/right
map('n', '<M-h>', '<cmd>BufferLineMovePrev<CR>', { desc = "Move tab left" })
map('n', '<M-l>', '<cmd>BufferLineMoveNext<CR>', { desc = "Move tab right" })

-- Safe buffer close
vim.keymap.set("n", "<leader>c", function()
  require("snacks").bufdelete()
end, { desc = "Close current tab safely" })

-- Buffer cycling
vim.keymap.set('n', '<S-h>', '<cmd>BufferLineCyclePrev<CR>', { desc = "Previous buffer" })
vim.keymap.set('n', '<S-l>', '<cmd>BufferLineCycleNext<CR>', { desc = "Next buffer" })

-- Resume last Telescope search
vim.keymap.set('n', '<leader>f', '<cmd>Telescope resume<CR>', { desc = "Resume last search" })


-- ========================================================================== --
-- IDE layout command
-- ========================================================================== --
vim.api.nvim_create_user_command('IDE', function()
	vim.cmd('ToggleTerm')
	vim.cmd('NvimTreeOpen')
	vim.cmd('wincmd k')
end, {})

-- ========================================================================== --
-- Auto-close NvimTree when it's the last window
-- ========================================================================== --
vim.api.nvim_create_autocmd("WinClosed", {
	callback = function()
		vim.schedule(function()
			local wins = vim.api.nvim_list_wins()
			local standard_wins = {}

			for _, w in ipairs(wins) do
				if vim.api.nvim_win_get_config(w).relative == "" then
					table.insert(standard_wins, w)
				end
			end

			if #standard_wins == 1 then
				local buf = vim.api.nvim_win_get_buf(standard_wins[1])
				if vim.bo[buf].filetype == "NvimTree" then
					vim.cmd("qa")
				end
			end
		end)
	end,
})

-- ========================================================================== --
-- Ctrl+Tab in NvimTree jumps to code window
-- ========================================================================== --
vim.api.nvim_create_autocmd("FileType", {
	pattern = "NvimTree",
	callback = function(args)
		vim.keymap.set('n', '<C-Tab>', '<cmd>wincmd p<CR><cmd>BufferLineCycleNext<CR>', { buffer = args.buf })
		vim.keymap.set('n', '<C-S-Tab>', '<cmd>wincmd p<CR><cmd>BufferLineCyclePrev<CR>', { buffer = args.buf })
	end
})


-- Diff options
vim.opt.diffopt:append({ "algorithm:patience", "linematch:60" })
vim.opt.fillchars = { eob = " ", diff = " " }

-- ========================================================================== --
-- Open PDFs with Zathura, skip binary buffer
-- ========================================================================== --
vim.api.nvim_create_autocmd("BufReadCmd", {
	pattern = "*.pdf",
	callback = function(args)
		vim.fn.jobstart({ "zathura", args.file }, { detach = true })

		vim.schedule(function()
			vim.cmd("bprevious")

			if vim.api.nvim_get_current_buf() == args.buf then
				vim.cmd("enew")
			end

			if vim.api.nvim_buf_is_valid(args.buf) then
				vim.api.nvim_buf_delete(args.buf, { force = true })
			end
		end)
	end,
})
