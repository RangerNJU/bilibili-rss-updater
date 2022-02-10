#!/bin/sh
date=$(date +"%Y%m%d")
cd ~/.dotfiles/ShellScripts

while IFS= read -r line; do
    printf '%s\n' "$line" | awk '{print "./generateLinkAndDownLoad.sh " $0 }' >> $date.sh
done < <(awk 'NF' uids)

chmod +x $date.sh
cat ./$date.sh
./$date.sh
rm ./$date.sh
exit 0
