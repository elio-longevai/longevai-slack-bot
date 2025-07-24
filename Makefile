# Makefile for the Qualivita Slack Assistant

.PHONY: help install setup setup-pre-commit clean dev compile-requirements lint format health

# --- Variables ---
VENV_DIR := .venv
PYTHON := python3

# Venv-specific commands
UV := VIRTUAL_ENV=$(CURDIR)/$(VENV_DIR) $(VENV_DIR)/bin/uv
RUFF := $(VENV_DIR)/bin/ruff

# ====================================================================================
#  📚 Help & Project Standards
# ====================================================================================

help:
	@printf "\n\033[1m🤖 Welcome to the Qualivita Slack Assistant! Here are the available commands:\033[0m\n\n"
	@printf "  \033[36m%-25s\033[0m %s\n" "make setup" "🛠️  Run this first! Cleans, installs all dependencies, and sets up git hooks."
	@printf "\n\033[1m--- 🏗️  Development ---\033[0m\n"
	@printf "  \033[36m%-25s\033[0m %s\n" "make install" "📦 Install all project dependencies into a virtual environment."
	@printf "  \033[36m%-25s\033[0m %s\n" "make dev" "🚀 Start the Slack bot for development."
	@printf "\n\033[1m--- 📦 Dependency Management ---\033[0m\n"
	@printf "  \033[36m%-25s\033[0m %s\n" "make compile-requirements" "🔒 Compile requirements.in files to requirements.txt."
	@printf "\n\033[1m--- ✨ Code Quality ---\033[0m\n"
	@printf "  \033[36m%-25s\033[0m %s\n" "make format" "✨ Auto-format all code to match project style."
	@printf "  \033[36m%-25s\033[0m %s\n" "make lint" "🔍 Check all code for potential errors and style issues."
	@printf "\n\033[1m--- 🏥 Health & Diagnostics ---\033[0m\n"
	@printf "  \033[36m%-25s\033[0m %s\n" "make health" "🏥 Check health of all services and project dependencies."
	@printf "\n\033[1m--- 🧹 Housekeeping ---\033[0m\n"
	@printf "  \033[36m%-25s\033[0m %s\n" "make clean" "🧹 Remove all cache files, build artifacts, and virtual envs."
	@printf "\n\033[1;32m--- 📖 Quick Start Guide ---\033[0m\n"
	@printf "New to this project? Follow these steps:\n"
	@printf "  1. Copy \033[3m.env.example\033[0m to \033[3m.env\033[0m and add your API keys.\n"
	@printf "  2. Run \033[3mmake setup\033[0m to initialize your environment.\n"
	@printf "  3. Run \033[3mmake dev\033[0m to start the Slack bot.\n"
	@printf "  4. Follow the development workflow: code, \033[3mmake format\033[0m, \033[3mmake lint\033[0m, then commit!\n\n"

# ====================================================================================
#  ⚙️ Setup & Installation
# ====================================================================================

install: $(VENV_DIR)/touchfile
	@echo "\n📦 Installing project dependencies..."
	@echo "--> Installing production dependencies from requirements.txt..."
	@$(UV) pip install -r requirements.txt
	@echo "--> Installing development dependencies from requirements-dev.txt..."
	@$(UV) pip install -r requirements-dev.txt
	@echo "\n✅ All dependencies installed successfully!"

# A touchfile is used to check if the venv exists and is up-to-date.
# This target runs if the venv directory doesn't exist OR if requirements files have changed.
$(VENV_DIR)/touchfile: requirements.txt requirements-dev.txt
	@if [ ! -d "$(VENV_DIR)" ]; then \
		echo "--> Creating Python virtual environment in $(VENV_DIR)..."; \
		$(PYTHON) -m venv $(VENV_DIR); \
	fi
	@if [ ! -f "$(VENV_DIR)/bin/uv" ]; then \
		echo "--> Installing uv into the virtual environment..."; \
		$(VENV_DIR)/bin/pip install --upgrade pip; \
		$(VENV_DIR)/bin/pip install uv; \
	else \
		echo "--> uv already installed in the virtual environment."; \
	fi
	@touch $@

setup: clean install setup-pre-commit
	@echo "\n🎉 Hooray! Your development environment is ready to go! 🎉"
	@echo "Next steps:"
	@echo "  1. If you haven't, copy '.env.example' to '.env' and fill it out."
	@echo "  2. Run 'make dev' to start the Slack bot."

# ====================================================================================
#  📦 Dependency Management
# ====================================================================================

compile-requirements: $(VENV_DIR)/touchfile
	@echo "\n🔒 Compiling dependencies from requirements.in files..."
	@echo "--> Using uv to compile. This will upgrade packages to their latest compatible versions."
	@$(UV) pip compile requirements.in -o requirements.txt --upgrade
	@$(UV) pip compile requirements-dev.in -o requirements-dev.txt --upgrade
	@echo "\n✅ Dependencies compiled successfully!"
	@echo "--> Review the changes in 'requirements.txt' and 'requirements-dev.txt' and commit the files."

# ====================================================================================
#  🧹 Housekeeping
# ====================================================================================

clean:
	@echo "\n🧹 Cleaning project artifacts..."
	@rm -rf $(VENV_DIR)
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@echo "\n✅ Project is sparkling clean!"

# ====================================================================================
#  🚀 Development & Execution
# ====================================================================================

dev: install
	@echo "\n🚀 Starting Qualivita Slack Assistant..."
	@echo "--> Make sure your .env file is configured with your tokens!"
	@echo "--> Press CTRL+C to stop the bot."
	@echo ""
	@$(VENV_DIR)/bin/python -m src.bot

# ====================================================================================
#  ✨ Code Quality
# ====================================================================================

lint: install
	@echo "\n🔍 Linting code with Ruff..."
	@$(RUFF) check .
	@echo "\n✅ Linting complete."

format: install
	@echo "\n✨ Auto-formatting code with Ruff..."
	@$(RUFF) format .
	@echo "--> Auto-fixing fixable lint issues..."
	@$(RUFF) check . --fix
	@echo "\n✅ Code formatting complete."

# ====================================================================================
#  🏥 Health & Diagnostics
# ====================================================================================

health:
	@echo "\n🏥 Checking system health..."
	@echo "\n--- 📋 Environment Check ---"
	@command -v $(PYTHON) >/dev/null 2>&1 && echo "✅ Python: $(shell which $(PYTHON))" || echo "❌ Python: Not found"
	@command -v git >/dev/null 2>&1 && echo "✅ Git: $(shell which git)" || echo "❌ Git: Not found"
	@echo "\n--- 📁 Project Files ---"
	@if [ -f "requirements.txt" ]; then echo "✅ requirements.txt found"; else echo "❌ requirements.txt missing"; fi
	@if [ -f "requirements-dev.txt" ]; then echo "✅ requirements-dev.txt found"; else echo "❌ requirements-dev.txt missing"; fi
	@if [ -f ".env" ]; then echo "✅ .env file found"; else echo "⚠️  .env file missing (copy from .env.example)"; fi
	@if [ -d "src" ]; then echo "✅ src directory found"; else echo "❌ src directory missing"; fi
	@echo "\n--- 🐍 Virtual Environment ---"
	@if [ -d "$(VENV_DIR)" ]; then echo "✅ Virtual environment exists"; else echo "❌ Virtual environment missing (run 'make install')"; fi
	@echo "\n🏁 Health check complete!"

# ====================================================================================
#  🪝 Git Hooks
# ====================================================================================

setup-pre-commit:
	@echo "\n🪝 Setting up Git pre-commit hook..."
	@echo "--> This hook will automatically format and lint Python code before you commit."
	@mkdir -p .git/hooks
	@echo '#!/bin/bash' > .git/hooks/pre-commit
	@echo '# Pre-commit hook to run ruff format & check --fix on staged Python files.' >> .git/hooks/pre-commit
	@echo 'set -e' >> .git/hooks/pre-commit
	@echo '' >> .git/hooks/pre-commit
	@echo 'echo "--- Running Qualivita Pre-Commit Checks ---"' >> .git/hooks/pre-commit
	@echo '' >> .git/hooks/pre-commit
	@echo '# Get list of staged Python files' >> .git/hooks/pre-commit
	@echo 'STAGED_PY_FILES=$$(git diff --cached --name-only --diff-filter=ACM | grep "\.py$$" || true)' >> .git/hooks/pre-commit
	@echo 'if [ -z "$$STAGED_PY_FILES" ]; then' >> .git/hooks/pre-commit
	@echo '    echo "✅ No Python files staged for commit. Skipping checks."' >> .git/hooks/pre-commit
	@echo 'else' >> .git/hooks/pre-commit
	@echo '    echo "✨ Formatting staged Python files..."' >> .git/hooks/pre-commit
	@echo '    echo "$$STAGED_PY_FILES" | xargs $(RUFF) format' >> .git/hooks/pre-commit
	@echo '    echo "🔍 Linting and auto-fixing staged Python files..."' >> .git/hooks/pre-commit
	@echo '    echo "$$STAGED_PY_FILES" | xargs $(RUFF) check --fix' >> .git/hooks/pre-commit
	@echo '    echo "--> Re-staging modified Python files..."' >> .git/hooks/pre-commit
	@echo '    echo "$$STAGED_PY_FILES" | xargs git add' >> .git/hooks/pre-commit
	@echo 'fi' >> .git/hooks/pre-commit
	@echo '' >> .git/hooks/pre-commit
	@echo 'echo "--- ✅ Pre-Commit Checks Passed! ---"' >> .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "--> Pre-commit hook has been installed and made executable."
	@echo "\n✅ Git hook setup is complete! It will run automatically on your next \`git commit\`."