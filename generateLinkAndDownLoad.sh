#!/bin/sh
#RSS地址自行修改
uid=$1
outputdir=~/VidRSS/$2

removeday=$(date -d "-14 day" +"%Y%m%d")
lastUpdateDay=$(date -d "-7 day" +"%Y%m%d")
date=$(date +"%Y%m%d")

removeUpdate=$uid@$removeday
lastUpdate=$uid@$lastUpdateDay
todayUpdate=$uid@$date

echo Remove: $removeUpdate
echo LastUpdate: $lastUpdate
echo LatestUpdate: $todayUpdate

#remove old update
[ -f "$removeUpdate" ] && rm -v $removeUpdate

#process DOWNLOAD_AV_LIST
#DOWNLOAD_AV_LIST=downloadAvList.txt
DOWNLOAD_LINK_LIST=download\_$uid\_$date.txt

echo "Downloading latest update" $uid@$date" ..."
[ ! -f $todayUpdate ] && curl -x 127.0.0.1:7890 https://rsshub.app/bilibili/user/dynamic/$uid -o $todayUpdate
echo "Latest update downloaded."

if [ ! -f "$lastUpdate" ]; then
    echo "$lastUpdate does not exsit, prepare to download all updated videos."
    grep -oE "av[0-9]*" $todayUpdate | sed 's/^/https:\/\/www.bilibili.com\/video\//' > $DOWNLOAD_LINK_LIST
else
    echo "$lastUpdate exsits, prepare to download new updated videos."
    TMPFILE=$(mktemp) || exit 1
    comm -13 <(sort $lastUpdate) <(sort $todayUpdate) > $TMPFILE
    grep -oE "av[0-9]*" $TMPFILE | sed 's/^/https:\/\/www.bilibili.com\/video\//' > $DOWNLOAD_LINK_LIST
fi

echo "Start downloading" $uid "to" $outputdir

#awk '{print "https://www.bilibili.com/video/" $0}' $DOWNLOAD_AV_LIST > $DOWNLOAD_LINK_LIST

mkdir -vp $outputdir
while true
do
    echo 'you-get --no-caption -o' $outputdir '-I' $DOWNLOAD_LINK_LIST
    you-get --no-caption -o $outputdir -I $DOWNLOAD_LINK_LIST
    if [ $? -eq 0 ]; then
        echo "Downloaded." $uid "to" $outputdir
        break;
    else
        sleep 2
    fi
done
