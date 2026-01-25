IMAGE_NAME := gemini-cli-toolbox/hub
DOCKER_FILE := Dockerfile
CONTEXT := .

.PHONY: build rebuild pre-build clean-artifacts

pre-build:
	@echo ">> Copying gemini-toolbox script..."
	cp ../../bin/gemini-toolbox .

clean-artifacts:
	@echo ">> Cleaning artifacts..."
	rm -f gemini-toolbox

build: pre-build
	docker build -t $(IMAGE_NAME):latest -f $(DOCKER_FILE) .
	$(MAKE) clean-artifacts

rebuild: pre-build
	docker build --no-cache -t $(IMAGE_NAME):latest -f $(DOCKER_FILE) .
	$(MAKE) clean-artifacts

ci: rebuild
