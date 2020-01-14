#!/bin/sh

_ssh() {
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $@
}

_ssh $1 sudo salt-key -F master --out json | jq -r '.local["master.pub"] | { fingerprint: . }' >&3
