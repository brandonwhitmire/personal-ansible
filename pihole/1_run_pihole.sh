#!/usr/bin/env bash

set -u

# Name used for tagging, hostname, etc.
export DOCKER_NAME="pihole"

# ---

docker images rm "$DOCKER_NAME" 2>/dev/null

set -e

docker build \
	--tag "$DOCKER_NAME" \
	--file Dockerfile \
	--compress \
	--build-arg UID="$(id -u)" \
	--build-arg GUID="$(id -g)" \
	. 
	# preserve this dot '.'

docker run \
	--hostname "$DOCKER_NAME" \
	--rm \
	--interactive=true \
	--tty=true \
	--user "$(id -u):$(id -g)" \
	--publish 127.0.0.1:8000:80/tcp \
	--publish 127.0.0.1:5300:53/udp \
	"$DOCKER_NAME"
