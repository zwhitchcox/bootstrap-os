#!/bin/bash

TOKEN_MNT=${TOKEN_MNT:-/tmp/token_mnt}
LABEL=${TOKEN_LABEL:-token}

err_exit() {
  echo "$@" > /dev/stderr
  exit 1
}

[ -z "$1" ] && err_exit "must supply path to drive"
disk="$1"

get_part_base() {
  if [[ $1 == /dev/sd* ]]; then
    echo $1
  elif [[ $1 == /dev/nvme* ]]; then
    echo $1p
  else
    err_exit "unrecognized base $disk"
  fi
}

create_partition_table() {
  sudo parted "$disk" -- mklabel gpt
  sudo parted "$disk" -- mkpart fat32 1MiB 512MiB
  sudo parted "$disk" -- mkpart ext4 512MiB 100%
}

create_file_systems() {
  part_base="$(get_part_base "$disk")"
  mkfs.fat -F 32 -n $LABEL "$part_base"1
  mkfs.ext4 -L data "$part_base"2
}

ensure_gh_token() {
  [ -n "$GH_TOKEN" ] && return 0
  printf 'Enter github personal access token: '
  read GH_TOKEN
}

mount_token_fs() {
  mkdir -p $TOKEN_MNT
  sudo mount "/dev/disk/by-label/$LABEL" "$TOKEN_MNT"
  echo "$GH_TOKEN" > "$TOKEN_MNT"/github
  sudo umount $TOKEN_MNT
}

create_partition_table
create_file_systems
ensure_gh_token
mount_token_fs
