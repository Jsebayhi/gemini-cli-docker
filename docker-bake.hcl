variable "IMAGE_TAG" {
  default = "latest"
}

group "default" {
  targets = ["base", "hub", "cli", "cli-preview", "hub-test", "bash-test"]
}

target "base" {
  context = "images/gemini-base"
  tags = ["gemini-cli-toolbox/base:${IMAGE_TAG}"]
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

target "hub" {
  context = "images/gemini-hub"
  contexts = {
    bin = "bin"
  }
  tags = ["gemini-cli-toolbox/hub:${IMAGE_TAG}"]
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

target "cli" {
  context = "images/gemini-cli"
  contexts = {
    "gemini-cli-toolbox/base:${IMAGE_TAG}" = "target:base"
    bin = "bin"
  }
  args = {
    BASE_TAG = "${IMAGE_TAG}"
  }
  tags = ["gemini-cli-toolbox/cli:${IMAGE_TAG}"]
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

target "cli-preview" {
  context = "images/gemini-cli-preview"
  contexts = {
    "gemini-cli-toolbox/base:${IMAGE_TAG}" = "target:base"
    bin = "bin"
  }
  args = {
    BASE_TAG = "${IMAGE_TAG}"
  }
  tags = ["gemini-cli-toolbox/cli-preview:${IMAGE_TAG}"]
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

target "hub-test" {
  context = "images/gemini-hub"
  dockerfile = "tests/Dockerfile"
  tags = ["gemini-hub-test:latest"]
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

target "bash-test" {
  context = "tests/bash"
  tags = ["gemini-bash-tester:latest"]
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}
