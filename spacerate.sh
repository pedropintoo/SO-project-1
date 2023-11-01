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

declare -A new_array
while read -r size path; do
  new_array["$path"]=$size
done <<< "$(awk '{ print $1, $2; }' "$new_file")"

declare -A old_array
while read -r size path; do
  old_array["$path"]=$size
done <<< "$(awk '{ print $1, $2; }' "$old_file")"



#
#while IFS= read -r new_line;
#do
#  echo "$new_line"
#done < "$new_file"

# o size está no ${partsNewDirectory[-1]}