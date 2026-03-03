#!/bin/bash

NP="172.16.88"
KH="$HOME/.ssh/known_hosts"

echo "Scanning $NP.0/16 for SSH hosts..."

for i in $(seq 1 254)
do
    IP="$NP.$i"

    (
        if ssh-keygen -F $IP > /dev/null; then
            exit
        fi

        KEY=$(ssh-keyscan -T 3 -H $IP 2>/dev/null)

        if [ -n "$KEY" ]; then
            echo "Adding $IP"
            echo "$KEY" >> "$KH"
        fi
    ) &

    # limit parallel jobs to avoid network storm
    while [ "$(jobs -r | wc -l)" -ge 20 ]; do
        sleep 0.5
    done

done

wait
echo "Done."
