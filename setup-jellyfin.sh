#!/usr/bin/env bash

set -x

incus stop jellyfin
incus delete jellyfin

incus launch images:debian/12 jellyfin

incus exec jellyfin -- apt-get -y install curl gnupg # software-properties-common
# incus exec jellyfin -- add-apt-repository universe

rm jellyfin.gpg
curl -fsSL 'https://repo.jellyfin.org/jellyfin_team.gpg.key' | gpg --dearmor -o jellyfin.gpg

incus file push ./jellyfin.gpg jellyfin/etc/apt/keyrings/jellyfin.gpg -pv
incus file push ./jellyfin.sources jellyfin/etc/apt/sources.list.d/jellyfin.sources -pv

incus exec jellyfin -- apt-get update
incus exec jellyfin -- apt-get -y install jellyfin

incus exec jellyfin -- apt-get -y install nginx

incus file push ./jellyfin.conf jellyfin/etc/nginx/conf.d/jellyfin.conf -pv
incus file push ./jellyfin.crt jellyfin/etc/nginx/ssl/jellyfin.crt -pv
incus file push ./jellyfin.key jellyfin/etc/nginx/ssl/jellyfin.key -pv
incus file push ./ca.crt jellyfin/etc/nginx/ssl/ca.crt -pv

incus config device add jellyfin movies disk source=/srv/nfs/nas/media/movies path=/media/movies
incus config device add jellyfin shows disk source=/srv/nfs/nas/media/television path=/media/shows

incus file delete jellyfin/etc/nginx/sites-enabled/default -v

incus exec jellyfin -- systemctl restart nginx
