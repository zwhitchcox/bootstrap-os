# create new ssh keys

TOKEN_DIR=${TOKEN_DIR:-/tmp/token}

err_exit() {
  echo "$@" > /dev/stderr
  exit 1
}

ensure_github_token() {
  [ -n "$GH_TOKEN" ] && return 0
  [ -f "$TOKEN_DIR"/github ] && export GH_TOKEN="$(cat "$TOKEN_DIR"/github)" && return 0
  err_exit "Couldn't find github token."
}

ensure_github_email() {
  [ -n "$GITHUB_EMAIL" ] && return 0
  export GITHUB_EMAIL="$(curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token $GH_TOKEN" \
    https://api.github.com/user/emails | jq -r '.[] | select(.primary == true) | .email')" || return 1
}

create_ssh_keys() {
  local key_file="$HOME/.ssh/id_rsa"
  [ -f "$key_file" ] && return 0
  mkdir -p "$HOME/.ssh" || return 1
  ssh-keygen -C "$GITHUB_EMAIL" -t rsa -b 4096 -f "$key_file" -P ''
}

ensure_github_token
create_ssh_keys
