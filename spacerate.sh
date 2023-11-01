#!/bin/bash

#######################################
# Defaults
#######################################
sort_option="-k1,1nr"
#######################################
#######################################


while getopts "ra" opt 2>/dev/null; do
  case "$opt" in
    r)
      if [[ "$sort_option" = "-k1,1nr" ]]; then
        sort_option="-k1,1n -k1,1r -k2,2r"
      else
        sort_option="-k2,2 -k1,1n -k1,1r" # -a -r
      fi
      ;;
    a)
      if [[ "$sort_option" = "-k1,1nr" ]]; then
        sort_option="-k2,2"
      else
        sort_option="-k1,1n -k1,1r -k2,2"  # -r -a
      fi
      ;;
    *) usage ;;
  esac
done

# removes options and their associated values,
# allows your script to access and process the non-option arguments
shift $((OPTIND-1))

new_file="$1"
old_file="$2"

# header
echo "SIZE NAME"

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


#for path in "${!new_array[@]}"; do
 # echo "NEW: ${new_array["$path"]} $path"
#done

#for path in "${!old_array[@]}"; do
 # echo "OLD: ${old_array["$path"]} $path"
#done


{

  for path in "${!new_array[@]}"; do
      if [[ -v old_array["$path"] ]]; then
          echo $((new_array["$path"] - old_array["$path"])) $path
      else
          echo ${new_array["$path"]} $path "NEW"
      fi
  done

  for path in "${!old_array[@]}"; do
      if [[ -v new_array["$path"] ]]; then
          continue
      else
          echo $((-old_array["$path"])) $path "REMOVED"
      fi
  done

} | sort $sort_option
