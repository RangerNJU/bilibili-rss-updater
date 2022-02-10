#!/bin/sh
#RSS地址自行修改
uid=$1
outputdir=~/VidRSS/$2
removeday=$(date -d "-2 day" +"%Y%m%d")
lastUpdateDay=$(date -d "-1 day" +"%Y%m%d")
date=$(date +"%Y%m%d")
removeUpdate=$uid@$removeday
lastUpdate=$uid@$lastUpdateDay
todayUpdate=$uid@$date
echo Remove: $removeUpdate
echo LastUpdate: $lastUpdate
echo LatestUpdate: $todayUpdate

#remove old update
[ -f "$removeUpdate" ] && rm -v $removeUpdate

DOWNLOAD_LINK_LIST=download\_$2\_$uid\_$date.txt
echo "Downloading latest update" $uid@$date" ..."
[ ! -f $todayUpdate ] && curl -x 127.0.0.1:7890 https://rsshub.app/bilibili/user/dynamic/$uid -o $todayUpdate
echo "Latest update downloaded."

if [ ! -f "$lastUpdate" ]; then
    echo "$lastUpdate does not exsit, prepare to download all updated videos."
    grep -oE "av[0-9]+" $todayUpdate | sed 's/^/https:\/\/www.bilibili.com\/video\//' > $DOWNLOAD_LINK_LIST
else
    echo "$lastUpdate exsits, prepare to download new updated videos."
    TMPFILE1=$(mktemp) || exit 1
    TMPFILE2=$(mktemp) || exit 1
    grep -oE "av[0-9]+" $lastUpdate > $TMPFILE1
    grep -oE "av[0-9]+" $todayUpdate > $TMPFILE2
    #echo TMPFILE1:
    #cat $TMPFILE1
    #echo TMPFILE2:
    #cat $TMPFILE2
    comm -13 <(sort $TMPFILE1) <(sort $TMPFILE2) | sed 's/^/https:\/\/www.bilibili.com\/video\//' > $DOWNLOAD_LINK_LIST
fi

echo "Start downloading" $uid "to" $outputdir
if [ ! -s $DOWNLOAD_LINK_LIST ]; then
    echo "File is empty:" $DOWNLOAD_LINK_LIST". Exit."
    exit 0
fi
mkdir -vp $outputdir
TRYTIMES=5
(( ++TRYTIMES ))
while (( --TRYTIMES >= 0 )); do
    echo 'you-get --no-caption -o' $outputdir '-I' $DOWNLOAD_LINK_LIST
    you-get --no-caption -o $outputdir -I $DOWNLOAD_LINK_LIST
    if [ $? -eq 0 ]; then
        echo "Downloaded." $uid "to" $outputdir
        break;
    else
        sleep 2
    fi
done

for i in $outputdir/*; do echo "${i/[\?|\!|\:]/}"; done
echo "Filename preprocessed, ready for adb push."

echo "Finished!"
