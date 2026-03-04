#!/bin/bash

NP="172.16.88"
touch $HOME/.ssh/known_hosts
KH="$HOME/.ssh/known_hosts"
uname="synnefo"
echo "Scanning $NP.0/16 for SSH hosts..."

for i in $(seq 1 120)
do
    IP="$NP.$i"

    (
        if ssh-keygen -F $IP > /dev/null; then
            exit
        fi

        KEY=$(ssh-keyscan -T 3 -H $IP)

        if [ -n "$KEY" ]; then
            echo "Adding $IP"
            echo "$KEY" >> "$KH"
	    echo "Securely Copying SSH-Key"
	    sshpass -p "asd123." ssh-copy-id $uname@$IP
        fi
    ) &

    # limit parallel jobs to avoid network storm
    while [ "$(jobs -r | wc -l)" -ge 20 ]; do
        sleep 0.5
    done

done

wait
echo "Done."
