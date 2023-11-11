#!/bin/bash

#######################################
# Command error message
# Outputs:
#   Output to STDERR
#######################################
usage() { echo "Usage: $0 [-r] [-a] [new_file] [old_file]" 1>&2; exit 1; }

#######################################
# Invalid directory error
# Outputs:
#   Output to STDERR
#######################################
invalidFile() { echo "ERROR: \"$1\" file is invalid." 1>&2; exit 1; }


#######################################
# Defaults
#######################################
sort_option="-k1,1nr"
#######################################
#######################################

# Arguments
# getopts to parse command-line options
while getopts "ra" opt 2>/dev/null; do
  case "$opt" in
    r)
      if [[ "$sort_option" = "-k1,1nr" ]]; then
        sort_option="-k1,1n -k1,1r -k2 -r"
      else
        sort_option="-k2 -r" # -a -r
      fi
      ;;
    a)
      if [[ "$sort_option" = "-k1,1nr" ]]; then
        sort_option="-k2"
      else
        sort_option="-k1,1n -k1,1r -k2"  # -r -a
      fi
      ;;
    *) usage ;;
  esac
done

# removes options and their associated values,
# allows your script to access and process the non-option arguments
shift $((OPTIND-1))


[[ "$#" -eq 2 ]] || usage

new_file="$1"
[[ -r "$new_file" ]] || invalidFile "$new_file"

old_file="$2"
[[ -r "$old_file" ]] || invalidFile "$old_file"

# header
echo "SIZE NAME"

content_new_file="$(tail -n +2 "$new_file" | awk '{ path=$2; for(i=3; i<=NF; i++) path=path" "$i; print $1, path }')"
content_old_file="$(tail -n +2 "$old_file" | awk '{ path=$2; for(i=3; i<=NF; i++) path=path" "$i; print $1, path }')"

# Save content of new file
declare -A new_array
while read -r size path; do
  new_array["$path"]=$size
done <<< "$content_new_file"

# Save content of old file
declare -A old_array
while read -r size path; do
  old_array["$path"]=$size
done <<< "$content_old_file"

# Convert new array to not cumulative sum
while read -r size path; do
  father_path="$path"
  while true; do
    [[ "${father_path%/*}" = "${father_path##/*}" ]] && break
    father_path="${father_path%/*}"
    new_array["$father_path"]=$((${new_array["$father_path"]} - ${new_array["$path"]}))
  done
done <<< "$(sort -k2 -r <<< "$content_new_file")"

# Convert old array to not cumulative sum
while read -r size path; do
  father_path="$path"
  while true; do
    [[ "${father_path%/*}" = "${father_path##/*}" ]] && break
    father_path="${father_path%/*}"
    old_array["$father_path"]=$((${old_array["$father_path"]} - ${old_array["$path"]}))
  done
done <<< "$(sort -k2 -r <<< "$content_old_file")"



# Process the data
{

  # Check differences and NEW directories
  for path in "${!new_array[@]}"; do

    if [[ ${old_array["$path"]} ]]; then
      if [[ ${new_array["$path"]} == "NA" ]]; then
        echo "NA" $path
      else
        echo $((${new_array["$path"]} - ${old_array["$path"]})) $path
      fi
    else
      echo ${new_array["$path"]} $path "NEW"
    fi
  done

  # Check for REMOVED directories
  for path in "${!old_array[@]}"; do
    if [[ ! "${new_array["$path"]}" ]]; then
      echo "-${old_array["$path"]}" $path "REMOVED"
    fi
  done

} | sort $sort_option
