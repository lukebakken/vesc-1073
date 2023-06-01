#!/usr/bin/env bash

# set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

readonly queue_name_prefix="delete-me-"

readonly rabbitmq_node="${1:-rabbit}"
readonly rabbitmq_vhost="${2:-/}"

_tmp_file="$(mktemp)"
readonly tmp_file="$_tmp_file"
unset _tmp_file

trap 'rm -vf $tmp_file' EXIT

rabbitmqctl -n "$rabbitmq_node" list_queues --vhost "$rabbitmq_vhost" --no-table-headers --quiet name consumers messages_ready > "$tmp_file"

declare -i consumers
declare -i messages_ready

while IFS=$'\t' read -r name consumers messages_ready
do
    if [[ $name == $queue_name_prefix* ]] && ((consumers == 0 && messages_ready == 0))
    then
        echo "[INFO] deleting queue: '$name'"
        # Note: https://unix.stackexchange.com/a/150128
        rabbitmqctl -n "$rabbitmq_node" delete_queue --vhost "$rabbitmq_vhost" "$name" < /dev/null
    fi
done < "$tmp_file"
