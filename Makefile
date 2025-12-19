# Master Makefile
# Orchestrates build tasks for all images in the repo

.PHONY: help build rebuild

.DEFAULT_GOAL := help

help:
	@echo "Project Orchestration"
	@echo "====================="
	@echo "  make build       : Build all images (Base -> CLI)"
	@echo "  make rebuild     : Force rebuild (no cache) of all images"

# Sequential build to ensure Base is ready before CLI
build:
	@echo ">> Building gemini-base..."
	$(MAKE) -C images/gemini-base build
	@echo ">> Building gemini-cli..."
	$(MAKE) -C images/gemini-cli build

# Sequential rebuild
rebuild:
	@echo ">> Rebuilding gemini-base (no cache)..."
	$(MAKE) -C images/gemini-base rebuild
	@echo ">> Rebuilding gemini-cli (no cache)..."
	$(MAKE) -C images/gemini-cli rebuild
