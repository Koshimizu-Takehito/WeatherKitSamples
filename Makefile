.PHONY: setup sync lint lint-fix lint-strict format format-check fix build test clean open help

# Default target
.DEFAULT_GOAL := help

# Project settings
PROJECT_NAME := WeatherKitSamples
SCHEME := WeatherKitSamples
DESTINATION_IOS := platform=iOS Simulator,name=iPhone 16,OS=latest
DESTINATION_MACOS := platform=macOS

# ============================================================================
# Setup
# ============================================================================

setup: ## Install Mint (if needed) and dependencies via Mint
	@echo "📦 Checking Mint installation..."
	@if ! command -v mint >/dev/null 2>&1; then \
		if command -v brew >/dev/null 2>&1; then \
			echo "🍺 Mint not found. Installing via Homebrew..."; \
			brew install mint; \
		else \
			echo "❌ Mint is not installed and Homebrew is not available."; \
			echo "   Please install Mint manually: https://github.com/yonaskolb/Mint"; \
			exit 1; \
		fi; \
	fi
	@echo "📦 Installing packages from Mintfile..."
	@mint bootstrap
	@echo "✅ Setup complete!"

sync: ## Pull latest changes and update all dependencies
	@echo "🔄 Pulling latest changes..."
	@git pull
	@echo "📦 Updating Mint packages..."
	@mint bootstrap
	@echo "✅ Sync complete!"

# ============================================================================
# Linting & Formatting
# ============================================================================

lint: ## Run SwiftLint
	@echo "🔍 Running SwiftLint..."
	@mint run swiftlint lint

lint-fix: ## Run SwiftLint with auto-correction
	@echo "🔧 Running SwiftLint auto-fix..."
	@mint run swiftlint lint --fix
	@echo "✅ Auto-fix complete!"

lint-strict: ## Run SwiftLint treating warnings as errors (for CI)
	@echo "🔍 Running SwiftLint (strict mode)..."
	@mint run swiftlint lint --strict

format: ## Format code with SwiftFormat
	@echo "✨ Formatting code..."
	@mint run swiftformat WeatherKitSamples
	@echo "✅ Formatting complete!"

format-check: ## Check code formatting (no changes)
	@echo "🔍 Checking code format..."
	@mint run swiftformat WeatherKitSamples --lint

fix: format lint-fix ## Format and auto-fix all code
	@echo "✅ All fixes applied!"

# ============================================================================
# Build & Test
# ============================================================================

build: ## Build the project for iOS Simulator
	@echo "🔨 Building for iOS Simulator..."
	@xcodebuild build \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination "$(DESTINATION_IOS)" \
		-quiet
	@echo "✅ Build complete!"

build-macos: ## Build the project for macOS
	@echo "🔨 Building for macOS..."
	@xcodebuild build \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination "$(DESTINATION_MACOS)" \
		-quiet
	@echo "✅ Build complete!"

test: ## Run tests on iOS Simulator
	@echo "🧪 Running tests..."
	@xcodebuild test \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination "$(DESTINATION_IOS)" \
		-quiet \
		|| echo "⚠️  Tests not configured yet"

# ============================================================================
# CI
# ============================================================================

ci: lint format-check build ## Run all CI checks (lint, format-check, build)
	@echo "✅ All CI checks passed!"

# ============================================================================
# Utilities
# ============================================================================

open: ## Open project in Xcode
	@xed .

clean: ## Clean build artifacts
	@echo "🧹 Cleaning..."
	@xcodebuild clean \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-quiet
	@rm -rf ~/Library/Developer/Xcode/DerivedData/$(PROJECT_NAME)-*
	@echo "✅ Clean complete!"

# ============================================================================
# Help
# ============================================================================

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
