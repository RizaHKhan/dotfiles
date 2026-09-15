DOTFILES := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

.PHONY: help
help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

.PHONY: nvim-env
nvim-env: ## Regenerate ~/.config/nvim/.env from 1Password (op read)
	DOTFILES="$(DOTFILES)" zsh "$(DOTFILES)/scripts/nvim-env.sh"