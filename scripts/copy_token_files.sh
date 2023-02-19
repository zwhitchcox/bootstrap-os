# copy key files (e.g. personal access token) from USB drive into temporary directory

TOKEN_MNT=${TOKEN_MNT:-/tmp/token_mnt}
TOKEN_DIR=${TOKEN_DIR:-/tmp/token}
TOKEN_DISK=${TOKEN_DISK:-/dev/disk/by-label/token}

err_exit() {
  echo "$@" > /dev/stderr
  exit 1
}

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
  ensure_empty_dir "$TOKEN_MNT"
  # create token directory
  ensure_empty_dir "$TOKEN_DIR"
  [ -e "$TOKEN_DISK" ] || err_exit '"token" disk not found'
  sudo mount "$TOKEN_DISK" "$TOKEN_MNT"
  cp -r "$TOKEN_MNT"/* "$TOKEN_DIR"
  sudo umount "$TOKEN_MNT"
}

main
