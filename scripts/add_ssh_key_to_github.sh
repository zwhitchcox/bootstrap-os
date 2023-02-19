
#!/bin/bash

# # get list of keys
# gh_list_keys() {
#   curl -s \
#     -H "Accept: application/vnd.github+json" \
#     -H "Authorization: token $GH_TOKEN" \
#     https://api.github.com/user/keys
# }
#
# # get key by title
# gh_key_by_title() {
#   list_keys | jq -r '.[] | "\(.id) \(.title)"'
# }
#
# # delete ssh key
# gh_key_del() {
#   local KEY_ID=$1
#   curl -s \
#     -X DELETE \
#     -H "Accept: application/vnd.github+json" \
#     -H "Authorization: token $GH_TOKEN" \
#     https://api.github.com/user/keys/$KEY_ID
# }

err_exit() {
  echo "$@" > /dev/stderr
  exit 1
}

ensure_github_token() {
  [ -n "$GH_TOKEN" ] && return 0
  [ -f "$TOKEN_DIR"/github ] && export GH_TOKEN="$(cat "$TOKEN_DIR"/github)" && return 0
  err_exit "Couldn't find github token."
}

ensure_github_in_known_hosts() {
  local key_file
  local keys
  key_file="$HOME/.ssh/known_hosts"
  keys=$(ssh-keyscan -H github.com 2>/dev/null) || return 1
  (echo "$keys" ; cat "$key_file") | sort | uniq -u > "$key_file.tmp"
  mv "$key_file.tmp" "$key_file"
}

ensure_ssh_key_exists() {
  test -f ~/.ssh/id_rsa.pub || err_exit "~/.ssh/id_rsa.pub not found"
}

add_ssh_key_to_github() {
  local output
  output=$(
    curl -s \
      -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $GH_TOKEN" \
      -d '{"key": "'"$(cat "$HOME/.ssh/id_rsa.pub")"'", "title": "'"$(hostname)"'"' \
      https://api.github.com/user/keys
  )
  #TODO test for error
  test $? -eq 0 && return
  if ! echo "$output" | grep -q "key is already in use"; then
    echo -e "could not add key\n$output" > /dev/stderr
    return 1
  else
    echo "key already added" 1>&2
  fi
}

ensure_github_token
ensure_github_in_known_hosts
add_ssh_key_to_github
