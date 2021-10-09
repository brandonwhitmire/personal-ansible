#!/usr/bin/env bash

set -e

NAME="ansible_controller"

docker build \
	--tag "$NAME" \
	--file Dockerfile \
	--build-arg UID="$(id -u)" \
	--build-arg GUID="$(id -g)" \
	.
	# preserve this dot

docker run \
	--hostname "$NAME" \
	--rm \
	--interactive=true \
	--tty=true \
	--volume "$(pwd)":"/root/ansible" \
	--volume "$HOME"/.ssh:"/root/.ssh" \
	--workdir "/root/ansible" \
	"$NAME"
