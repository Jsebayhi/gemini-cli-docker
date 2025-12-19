IMAGE_NAME := gemini-base
IMAGE_TAG := latest

.PHONY: build rebuild

build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

rebuild:
	docker build --no-cache -t $(IMAGE_NAME):$(IMAGE_TAG) .
