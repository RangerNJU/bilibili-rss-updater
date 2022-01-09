#!/bin/sh
date=$(date +"%Y%m%d")
awk 'NF' uids | awk '{print "./generateLinkAndDownLoad.sh " $0}' > $date.sh
#awk 'NF' uids | awk '{print "./generateLinkAndDownLoad.sh " $0}' | xargs sh
chmod -v +x $date.sh
cat $date.sh
./$date.sh
rm -v $date.sh
