IMAGE_NAME := gemini-cli-toolbox/base

# Detect Branch and Suffix Tag
CURRENT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
SAFE_BRANCH := $(shell echo $(CURRENT_BRANCH) | sed 's/[^a-zA-Z0-9]/-/g')

ifeq ($(CURRENT_BRANCH),main)
    IMAGE_TAG := latest
else
    IMAGE_TAG := latest-$(SAFE_BRANCH)
endif

.DEFAULT_GOAL := help

.PHONY: help build rebuild scan

help:
	@echo "Gemini Base Image"
	@echo "================="
	@echo "  make build    : Build the Base image (OS + Sys Tools)"
	@echo "  make rebuild  : Force rebuild without cache (OS Updates)"
	@echo "  make scan     : Run security scan (Trivy) on this image"
	@echo "  make help     : Show this help message"

build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

rebuild:
	docker build --no-cache -t $(IMAGE_NAME):$(IMAGE_TAG) .

scan:
	@echo ">> Scanning $(IMAGE_NAME):$(IMAGE_TAG)..."
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		-v "$(shell pwd)/../../.trivyignore:/.trivyignore" \
		aquasec/trivy image --exit-code 1 --severity CRITICAL --ignore-unfixed --ignorefile /.trivyignore $(IMAGE_NAME):$(IMAGE_TAG)
