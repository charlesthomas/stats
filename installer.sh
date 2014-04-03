#!/bin/bash
# halt on any error
set -e

# check installing as root
if [[ $(id -u) -ne 0 ]]; then
    echo must be root
    exit 1
fi

# make log dir
mkdir -p /var/log/stats/

# install bins
cp -rvi bin/* /usr/bin/

# install init.d script
cp -vi init.d/stats_daemon /etc/init.d/
update-rc.d stats_daemon defaults
