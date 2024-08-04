#!/usr/bin/env bash

# To get additional terminals after running this container (interactively or otherwise), run:
# docker exec -it $(docker ps | grep ansible_controller | awk '{print $1}') zsh

set -u

# Name used for tagging, hostname, etc.
export DOCKER_NAME="ansible_controller"
# Outside, host folder to mount read-only from (e.g. for playbooks)
export DOCKER_HOST_MOUNT="$(git rev-parse --show-toplevel)/"

# ---

docker images rm "$DOCKER_NAME" 2>/dev/null

set -e

if [[ -n "$@" ]] ; then
	echo "Extra \`docker build\` Args: $@"
	echo
	sleep 2
fi

docker build \
	--tag "$DOCKER_NAME" \
	--file "$DOCKER_HOST_MOUNT"/Dockerfile \
	--compress \
	--build-arg UID="$(id --name --user)" \
	--build-arg GUID="$(id --name --group)" \
	--build-arg WORKDIR="/$DOCKER_NAME" \
	. 
	# preserve this dot '.'

docker run \
	--hostname "$DOCKER_NAME" \
	--rm \
	--interactive=true \
	--tty=true \
	--user "$(id --name --user):$(id --name --group)" \
	--volume "$DOCKER_HOST_MOUNT":"/$DOCKER_NAME" \
	--volume "$HOME"/.ssh:/home/"$(id --name --user)/.ssh:ro" \
	--workdir="/$DOCKER_NAME" \
    --env LIBVIRT_DEFAULT_URI \
    --volume /var/run/libvirt/:/var/run/libvirt/ \
    --volume ~/.vagrant.d:/.vagrant.d \
    --network host \
	"$DOCKER_NAME"
