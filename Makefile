TAG_NAME := hook-creator
DOCKERFILE := .github/workflows/Dockerfile
DOCKER := docker
CONTAINER_NAME := hook-creator
MOUNT_DIR := $(shell pwd)

.PHONY: build
build:
	$(DOCKER) build -f $(DOCKERFILE) -t $(TAG_NAME) .

.PHONY: devel
devel:
	$(DOCKER) run -it -w /mnt/ --rm --init -v $(MOUNT_DIR):/mnt --name $(CONTAINER_NAME) $(TAG_NAME) /bin/bash

.PHONY: test
test:
	$(DOCKER) run -itd -w /mnt/ -v $(MOUNT_DIR):/mnt --name $(CONTAINER_NAME) $(TAG_NAME) /bin/bash
	($(DOCKER) exec -w /mnt/ $(CONTAINER_NAME) /bin/bash -c "/root/.local/bin/shellspec -s /bin/bash" && \
	$(DOCKER) exec -w /mnt/ $(CONTAINER_NAME) /bin/bash -c "/root/.local/bin/shellspec -s /bin/zsh"  && \
	$(DOCKER) exec -w /mnt/ $(CONTAINER_NAME) /bin/bash -c "/root/.local/bin/shellspec -s /bin/dash" && /bin/false ) || \
	$(DOCKER) rm -f $(CONTAINER_NAME)
