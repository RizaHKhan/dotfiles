# Agent Guidelines for AstroNvim Configuration

## Build/Lint/Test Commands
- **Lint**: `stylua --check .` (format: `stylua .`)
- **Lint Lua**: `selene .` (static analysis)
- **Test**: This is a Neovim config - test by running `:checkhealth` in Neovim
- **Reload**: `:source` or `<leader>so` after editing

## Code Style
- **Language**: Lua 5.1 (Neovim runtime)
- **Formatter**: StyLua with config in `.stylua.toml`
- **Indent**: 4 spaces, Unix line endings, 120 column width
- **Quotes**: Auto-prefer double quotes
- **Call parentheses**: None (Lua style: `require "module"` not `require("module")`)
- **Comments**: Use `--` for single line, avoid unless necessary
- **Type annotations**: Use EmmyLua annotations (`---@type`, `---@param`)

## File Structure
- Plugin configs in `lua/plugins/*.lua` - each returns a LazySpec table
- Use `---@type LazySpec` annotation at top of plugin files
- Import community plugins in `lua/community.lua`
- Custom keymaps/options in `lua/plugins/astrocore.lua`

## Naming & Conventions
- Plugin files: lowercase with hyphens matching plugin name
- Functions: snake_case
- Never commit commented code - remove it
- Follow existing patterns from neighboring files before adding new code

Skip for:
- Small bug fixes
- Simple refactoring
- Configuration changes
- Trivial updates
