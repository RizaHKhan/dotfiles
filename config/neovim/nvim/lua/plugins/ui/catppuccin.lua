return {
	"catppuccin/nvim",
	lazy = false,
	name = "catppuccin",
	priority = 1000,

	config = function()
		require("catppuccin").setup({
			flavour = "mocha", -- or "latte", "frappe", "macchiato"
			transparent_background = true,
			auto_integrations = true, -- automatically load integrations
			integrations = {
				notify = true, -- pull in Notify* highlight groups
				gitsigns = true,
				telescope = true,
				mini = {
					enabled = true,
				},
				neotree = true,
				flash = true,
				cmp = true,
				dap = true,
				dap_ui = true,
				lsp_trouble = true,
				dadbod_ui = true,
				snacks = {
					enabled = true,
				},
			},
			styles = {
				functions = { "bold" },
				keywords = { "bold" },
				types = { "bold" },
			},
			dim_inactive = {
				enabled = false, -- dims the background color of inactive window
				shade = "light",
				percentage = 0.9, -- percentage of the shade to apply to the inactive window
			},
			custom_highlights = function(colors)
				local searchActive = { bg = colors.red, fg = "#181825" }
				local searchInactive = { bg = colors.peach, fg = "#000000" }
				-- GitHub Dark syntax palette from projekt0n/github-nvim-theme.
				local syntax = {
					comment = "#8b949e",
					constant = "#79c0ff",
					func = "#d2a8ff",
					keyword = "#ff7b72",
					string = "#a5d6ff",
					tag = "#7ee787",
					type = "#ffa657",
					variable = "#e6edf3",
				}

				return {
					CursorLineNr = { fg = colors.flamingo },

					-- Higher-contrast code syntax while retaining the Catppuccin UI.
					Comment = { fg = syntax.comment },
					Constant = { fg = syntax.constant },
					String = { fg = syntax.string },
					Number = { fg = syntax.constant },
					Boolean = { fg = syntax.constant },
					Identifier = { fg = syntax.variable },
					Function = { fg = syntax.func, bold = true },
					Statement = { fg = syntax.keyword, bold = true },
					Conditional = { fg = syntax.keyword, bold = true },
					Repeat = { fg = syntax.keyword, bold = true },
					Keyword = { fg = syntax.keyword, bold = true },
					Exception = { fg = syntax.keyword, bold = true },
					Operator = { fg = syntax.constant },
					PreProc = { fg = syntax.keyword },
					Type = { fg = syntax.type, bold = true },
					Tag = { fg = syntax.tag },

					["@variable"] = { fg = syntax.variable },
					["@variable.builtin"] = { fg = syntax.constant },
					["@variable.member"] = { fg = syntax.constant },
					["@variable.parameter"] = { fg = syntax.variable },
					["@constant"] = { fg = syntax.constant },
					["@constant.builtin"] = { fg = syntax.constant },
					["@string"] = { fg = syntax.string },
					["@type"] = { fg = syntax.type, bold = true },
					["@type.builtin"] = { fg = syntax.keyword, bold = true },
					["@property"] = { fg = syntax.constant },
					["@function"] = { fg = syntax.func, bold = true },
					["@function.call"] = { fg = syntax.func, bold = true },
					["@function.builtin"] = { fg = syntax.constant, bold = true },
					["@function.method"] = { fg = syntax.constant, bold = true },
					["@function.method.call"] = { fg = syntax.constant, bold = true },
					["@constructor"] = { fg = syntax.type },
					["@keyword"] = { fg = syntax.keyword, bold = true },
					["@keyword.function"] = { fg = syntax.keyword, bold = true },
					["@keyword.operator"] = { fg = syntax.keyword, bold = true },
					["@keyword.return"] = { fg = syntax.keyword, bold = true },
					["@operator.lua"] = { fg = syntax.keyword },
					["@lsp.type.function"] = { link = "@function" },
					["@lsp.type.method"] = { link = "@function.method" },
					["@lsp.type.parameter"] = { link = "@variable.parameter" },
					["@lsp.type.property"] = { link = "@property" },
					["@lsp.type.keyword"] = { link = "@keyword" },
					["@lsp.type.type"] = { link = "@type" },
					["@lsp.type.class"] = { link = "@type" },

					DiffAdd = { bg = "#0e4429" },
					DiffDelete = { bg = "#4c1f2b" },
					DiffChange = { bg = "#1f3152" },
					DiffText = { bg = "#2f4f78" },
					Search = searchInactive,
					IncSearch = searchActive,
					EndOfBuffer = { fg = colors.flamingo },
					NormalNC = {
						bg = "#171722",
					},
					WinSeparator = {
						fg = colors.surface0,
						bg = "NONE",
					},
					NormalFloat = {
						bg = colors.mantle,
					},
					FloatBorder = {
						fg = colors.surface0,
						bg = colors.mantle,
					},

					-- Completion menus
					Pmenu = {
						bg = colors.mantle,
						fg = colors.text,
					},

					PmenuSel = {
						bg = colors.surface0,
						fg = colors.text,
						bold = false,
					},

					PmenuBorder = {
						fg = colors.surface0,
						bg = colors.mantle,
					},

					PmenuSbar = {
						bg = colors.mantle,
					},

					PmenuThumb = {
						bg = colors.surface1,
					},

					-- Solid background for completion popup (overrides transparent_background)
					-- Pmenu = { bg = colors.mantle, fg = colors.text },
					-- PmenuSel = { bg = colors.surface0, fg = colors.text, bold = true },
					-- PmenuBorder = { fg = colors.surface1 },
					-- NormalFloat = { bg = colors.mantle, fg = colors.text },
					-- FloatBorder = { bg = colors.mantle, fg = colors.surface1 },
				}
			end,
		})
		vim.cmd.colorscheme("catppuccin")
	end,
}
