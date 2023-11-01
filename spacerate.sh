#!/bin/bash

# -------------------------------
# declare variables
# -------------------------------
new_file="$1"
old_file="$2"

sort_option="-k1,1nr"
# -------------------------------
# -------------------------------

# header
#echo "SIZE NAME"

tail -n +2 "$new_file" | while IFS= read -r new_line;
do

  IFS="/"


  directoryNew=$(echo "$new_line" | awk '{print $2}')
  sizeNew=$(echo "$new_line" | awk '{print $1}')

  read -ra partsNewDirectory <<< "$directoryNew"
  partsNewDirectory+=("$sizeNew")

  IFS=" "

  #echo ${partsNewDirectory[@]}
  #echo ${#partsNewDirectory[@]}


  tail -n +2 "$old_file" | while IFS= read -r old_line;
  do
    if [ "$firstLineOld" = true ]; then
      firstLineOld=false
      continue
    fi

    directoryOld=$(echo "$old_line" | awk '{print $2}')
    sizeOld=$(echo "$old_line" | awk '{print $1}')

    IFS="/"

    read -ra partsOldDirectory <<< "$directoryOld"
    partsOldDirectory+=("$sizeOld")

    for ((i=0; i<${#partsNewDirectory}; i++)); do
      if [ ${#partsNewDirectory[i]} -ge ${#partsOldDirectory[i]} ]; then
        echo $((partsNewDirectory[-1] - partsOldDirectory[-1]))
      fi
    done

  done

  firstLineOld=true

done #| sort -k2,2

# o size está no ${partsNewDirectory[-1]}