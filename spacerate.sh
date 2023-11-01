#!/bin/bash

# -------------------------------
# declare variables
# -------------------------------
new_file="$1"
old_file="$2"
# -------------------------------
# -------------------------------

# header
#echo "SIZE NAME"

# Save content of new file
declare -A new_array
while read -r size path; do
  new_array["$path"]=$size
  #echo "$path ${new_array["$path"]}"
done <<< "$(tail -n +2 "$new_file" | awk '{ print $1, $2; }')"

# Save content of old file
declare -A old_array
while read -r size path; do
  old_array["$path"]=$size
done <<< "$(tail -n +2 "$old_file" | awk '{ print $1, $2; }')"

# Convert new array to not cumulative sum
while read -r size path; do
  father_path="$path"
  while true; do
    [[ "${father_path%/*}" = "${father_path##/*}" ]] && break
    father_path="${father_path%/*}"
    new_array["$father_path"]=$(( new_array["$father_path"] - new_array["$path"] ))
  done
done <<< "$(tail -n +2 "$new_file" | awk '{ print $1, $2; }' | sort "-k2,2r" )"

# Convert old array to not cumulative sum
while read -r size path; do
  father_path="$path"
  while true; do
    [[ "${father_path%/*}" = "${father_path##/*}" ]] && break
    father_path="${father_path%/*}"
    old_array["$father_path"]=$(( old_array["$father_path"] - old_array["$path"] ))
  done
done <<< "$(tail -n +2 "$old_file" | awk '{ print $1, $2; }' | sort "-k2,2r" )"


for path in "${!new_array[@]}"; do
  echo "NEW: ${new_array["$path"]} $path"
done

for path in "${!old_array[@]}"; do
  echo "OLD: ${old_array["$path"]} $path"
done
