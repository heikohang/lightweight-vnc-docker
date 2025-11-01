# Makefile for Lightweight VNC Docker

# === Configuration ===
# You can override these variables on the command line
# Example: make VNC_PW=newpass run
IMAGE_NAME := lightweight-vnc
CONTAINER_NAME := my-persistent-desktop
VNC_PW := mypassword
VNC_RESOLUTION := 1920x1080

# Ports
VNC_PORT := 5901
WEB_PORT := 6901

# Persistent volume path (uses your host's home directory)
PERSISTENT_HOME := $(HOME)/my-vnc-home
SHM_SIZE := 1g

# === Targets ===
.PHONY: help all build run run-persistent start stop logs clean shell

# Set the default goal to 'help' so 'make' shows the options
.DEFAULT_GOAL := help

help:
	@echo "Available commands:"
	@echo ""
	@echo "  make build          - Build the docker image"
	@echo "  make run            - Run in ephemeral (start-fresh) mode"
	@echo "  make run-persistent - Run in persistent mode (saves data to $(PERSISTENT_HOME))"
	@echo "  make start          - Start the persistent container"
	@echo "  make stop           - Stop the persistent container"
	@echo "  make logs           - View logs from the persistent container"
	@echo "  make shell          - Get a bash shell inside the persistent container"
	@echo "  make clean          - Stop and remove the persistent container"
	@echo ""
	@echo "You can override variables, e.g.: make VNC_PW=newpass run"

# Build the Docker image
build:
	docker build -t $(IMAGE_NAME) .

# Run in ephemeral (start-fresh) mode.
# This is interactive; press Ctrl+C to stop and remove.
run: build
	@echo "--- Starting Ephemeral Session (http://localhost:$(WEB_PORT)) ---"
	docker run --rm -it \
		-p $(WEB_PORT):$(WEB_PORT) \
		-p $(VNC_PORT):$(VNC_PORT) \
		-e VNC_PW=$(VNC_PW) \
		-e VNC_RESOLUTION=$(VNC_RESOLUTION) \
		--shm-size=$(SHM_SIZE) \
		$(IMAGE_NAME)

# Run in persistent mode (detached)
run-persistent: build
	@echo "--- Starting Persistent Session (http://localhost:$(WEB_PORT)) ---"
	@echo "--- Data will be saved to $(PERSISTENT_HOME) ---"
	docker run -d \
		-p $(WEB_PORT):$(WEB_PORT) \
		-p $(VNC_PORT):$(VNC_PORT) \
		-e VNC_PW=$(VNC_PW) \
		-e VNC_RESOLUTION=$(VNC_RESOLUTION) \
		-v $(PERSISTENT_HOME):/home/docker \
		--shm-size=$(SHM_SIZE) \
		--name $(CONTAINER_NAME) \
		$(IMAGE_NAME)

# Start the existing persistent container
start:
	@echo "--- Starting container '$(CONTAINER_NAME)' ---"
	docker start $(CONTAINER_NAME)

# Stop the persistent container
stop:
	@echo "--- Stopping container '$(CONTAINER_NAME)' ---"
	docker stop $(CONTAINER_NAME)

# Follow the logs of the persistent container
logs:
	docker logs -f $(CONTAINER_NAME)

# Get an interactive shell inside the running persistent container
shell:
	docker exec -it $(CONTAINER_NAME) /bin/bash

# Stop AND remove the persistent container
# The '-' ignores errors if the container doesn't exist
clean:
	@echo "--- Stopping and removing container '$(CONTAINER_NAME)' ---"
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)