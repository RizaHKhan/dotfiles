return {
	"Isrothy/neominimap.nvim",
	version = "v3.x.x",
	lazy = false,
	init = function()
		vim.api.nvim_create_user_command("MiniMap", function()
			vim.cmd("Neominimap Toggle")
		end, {})

		local tmpdir = vim.env.TMPDIR or "/tmp"
		tmpdir = vim.fs.normalize(vim.uv.fs_realpath(tmpdir) or tmpdir)

		local function is_diff_tab(tabid)
			for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabid)) do
				local _, codediff = pcall(vim.api.nvim_win_get_var, winid, "codediff_restore")
				local bufnr = vim.api.nvim_win_get_buf(winid)
				local name = vim.api.nvim_buf_get_name(bufnr)
				local filetype = vim.bo[bufnr].filetype

				if codediff == 1
					or vim.startswith(name, "codediff://")
					or vim.startswith(name, "atlas-diff")
					or vim.startswith(filetype, "codediff")
					or vim.startswith(filetype, "atlas.diff")
				then
					return true
				end
			end

			return false
		end

		vim.g.neominimap = {
			auto_enable = true,
			buf_filter = function(bufnr)
				local path = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
				local basename = vim.fs.basename(path)
				local is_temporary = vim.startswith(path, tmpdir .. "/")
					and (basename:match("^zsh%w%w%w%w%w%w$") or vim.startswith(basename, ".tmp"))

				return not is_temporary
			end,
			tab_filter = function(tabid)
				return not is_diff_tab(tabid)
			end,
			layout = "float",
			float = {
				minimap_width = 14,
				window_border = "none",
			},
			winopt = function(opt)
				opt.winblend = 0
			end,
			click = {
				enabled = true,
				auto_switch_focus = true,
			},
		}
	end,
	config = function()
		local colors = require("catppuccin.palettes").get_palette()
		vim.api.nvim_set_hl(0, "NeominimapBackground", {
			fg = colors.text,
			bg = colors.mantle,
		})
	end,
}
