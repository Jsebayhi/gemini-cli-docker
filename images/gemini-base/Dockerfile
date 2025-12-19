# Base Image for Gemini Toolbox
# Contains: Node.js 20, OS Security Updates, Gosu, Git

FROM node:20-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# 1. Remove default 'node' user to free up UID 1000
RUN userdel -r node

# 2. System Updates & Essentials
# - upgrade: Apply latest security patches
# - gosu: for user switching
# - git, procps, findutils: Standard agent toolkit
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    gosu \
    git \
    ca-certificates \
    procps \
    findutils \
    && rm -rf /var/lib/apt/lists/*
