#!/bin/sh

_ssh() {
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $@
}

_ssh $1 sudo salt-call --local grains.fetch uuid --out json | jq -r '{ uuid: .local }' >&3
