#!/bin/sh
# Copy the renewed certificate to bnetserver and restart it (certs load only at startup).
set -eu
live=/etc/letsencrypt/live/wow.thomaspyle.com
bin=/opt/wow/forever/server/bin
install -o wow -g wow -m 644 "$live/fullchain.pem" "$bin/wow.cert.pem"
install -o wow -g wow -m 600 "$live/privkey.pem" "$bin/wow.key.pem"
systemctl restart forever-bnet
