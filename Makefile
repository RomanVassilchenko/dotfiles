.PHONY: format format-nix format-md format-sh kde-config help

# Default target
help:
	@echo "Available targets:"
	@echo "  make format     - Format all files (Nix, Markdown, Shell)"
	@echo "  make format-nix - Format only Nix files"
	@echo "  make format-md  - Format only Markdown files"
	@echo "  make format-sh  - Format only shell scripts"
	@echo "  make kde-config - Generate KDE config from current settings"
	@echo "  make help       - Show this help message"

# Format all files
format: format-nix format-md format-sh

# Format Nix files
format-nix:
	@echo "Formatting Nix files..."
	@find . -name "*.nix" -not -path "*/.*" -print0 | xargs -0 nixfmt

# Format Markdown files
format-md:
	@echo "Formatting Markdown files..."
	@find . -name "*.md" -not -path "*/.*" -print0 | xargs -0 prettier --write --prose-wrap always

# Format shell scripts
format-sh:
	@echo "Formatting shell scripts..."
	@find . -name "*.sh" -not -path "*/.*" -print0 | xargs -0 shfmt -w -i 2 -ci

# Generate KDE config from current settings
kde-config:
	@echo "Generating KDE config..."
	@rc2nix > modules/home/desktop/kde/config.nix
	@echo "Formatting generated config..."
	@nixfmt modules/home/desktop/kde/config.nix
	@echo "KDE config generated and formatted at modules/home/desktop/kde/config.nix"
