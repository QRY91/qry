# QRY Prompt Makefile

.PHONY: install install-fonts install-prompt test clean help

# Default target
help:
	@echo "QRY Prompt - Makefile"
	@echo "===================="
	@echo "Available targets:"
	@echo "  install        - Full installation (fonts + prompt)"
	@echo "  install-fonts  - Install nerd fonts only"
	@echo "  install-prompt - Install prompt only"
	@echo "  test           - Test font installation"
	@echo "  demo           - Show prompt demo"
	@echo "  clean          - Remove installation"
	@echo "  help           - Show this help message"

# Full installation
install:
	@echo "Installing QRY Prompt..."
	./install.sh

# Install fonts only
install-fonts:
	@echo "Installing nerd fonts..."
	./install.sh --fonts-only

# Install prompt only  
install-prompt:
	@echo "Installing prompt..."
	./install.sh --prompt-only

# Test installation
test:
	@echo "Testing font installation..."
	./install.sh --test

# Show demo
demo:
	@echo "QRY Prompt Demo:"
	@echo "================"
	@bash -c "source ./qry-prompt.sh && build_prompt" | sed 's/\\033\[[0-9;]*m//g'

# Clean installation
clean:
	@echo "Removing QRY Prompt..."
	@rm -rf ~/.local/share/qry-prompt
	@echo "Note: Nerd fonts and shell config modifications are left intact."
	@echo "Remove manually if desired."