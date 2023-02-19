# copy key files (e.g. personal access token) from USB drive into temporary directory

err_exit() {
  echo "$@" > /dev/stderr
  exit 1
}

KEYS_MNT=${KEYS_MNT:-/tmp/boostrap_keys}
KEYS_DIR=${KEYS_DIR:-/tmp/keys}
KEYS_DISK=${KEYS_DISK:-/dev/disk/by-label/keys}

ensure_empty_dir() {
  dir="$1"
  if [ ! -e "$dir" ]; then
    mkdir -p "$dir"
  elif [ ! -d "$dir" ]; then
    err_exit "$dir is not a directory"
  elif [ "$(ls "$dir")" != "" ]; then
    err_exit "$dir is not empty"
  fi
}

main() {
  # create mount point
  ensure_empty_dir "$KEYS_MNT"
  # create key directory
  ensure_empty_dir "$KEYS_DIR"
  [ -f "$KEYS_DISK" ] || err_exit '"keys" disk not found'
  sudo mount "$KEYS_DISK" "$KEYS_MNT"
  cp -r "$KEYS_MNT" "$KEYS_DIR"
  sudo umount "$KEYS_MNT"
}

main
