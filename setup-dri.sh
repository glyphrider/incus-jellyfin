#!/usr/bin/env bash

set -x

HOST_VIDEO=$(grep video /etc/group | cut -d: -f3)
HOST_RENDER=$(grep render /etc/group | cut -d: -f3)
incus exec jellyfin groupadd -g $HOST_VIDEO host_video
incus exec jellyfin groupadd -g $HOST_RENDER host_render
incus exec jellyfin usermod -aG host_video jellyfin
incus exec jellyfin usermod -aG host_render jellyfin
incus stop jellyfin
incus config device override jellyfin eth0 hwaddr='00:16:3E:91:31:07'
incus config device add jellyfin dri disk source=/dev/dri path=/dev/dri
incus start jellyfin
