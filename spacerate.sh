#!/bin/bash

# -------------------------------
# declare variables
# -------------------------------
newestFile="$1"
oldestFile="$2"
header="SIZE NAME"
sort_option="-k1,1nr"
# -------------------------------
# -------------------------------

firstLineNew=true
firstLineOld=true

while IFS= read -r lineNew
do

    IFS="/"

    if [ "$firstLineNew" = true ]; then
        firstLineNew=false
        continue
    fi

    directoryNew=$(echo "$lineNew" | awk '{print $2}')
    sizeNew=$(echo "$lineNew" | awk '{print $1}')

    read -ra partsNewDirectory <<< "$directoryNew"

    IFS=" "

    echo ${partsNewDirectory[@]}
    echo ${#partsNewDirectory[@]}


    while IFS= read -r lineOld
    do
        if [ "$firstLineOld" = true ]; then
            firstLineOld=false
            continue
        fi

        directoryOld=$(echo "$lineOld" | awk '{print $2}')
        sizeOld=$(echo "$lineOld" | awk '{print $1}')
        
        IFS="/"

        read -ra partsOldDirectory <<< "$directoryOld"

        IFS=" "

    done < "$oldestFile"

    firstLineOld=true

done < "$newestFile" #| sort -k2,2

