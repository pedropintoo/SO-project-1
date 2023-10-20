#!/bin/bash
source ./validation/spacecheck_validation.sh

# Error message: stdout -> stderr
usage() { echo "Usage: $0 [-d <date>] [-s <size>] [-l <limit>] [-r | -a] [-n <regex>] [<directory>]" 1>&2; exit 1; }


# --------------------------------------
# Defaults
# --------------------------------------
# header
echo "SIZE NAME $(date "+%Y%m%d") $*"

directory="."
sort_option="-k1,1nr" # default sort
size=0
name_exp=".*"
date_ref="0000-01-01 00:00:00"
# --------------------------------------
# --------------------------------------


# getopts to parse command-line options
while getopts "d:s:l:ran::" opt; do
  case "$opt" in
    d)
      # option -d active
      date_ref=$(LC_TIME=en_US.utf8 date -d "$OPTARG" "+%Y-%m-%d %H:%M:%S")
      ;;
    s)
      # option -s active
      size="$OPTARG"
      ;;
    l)
      # option -l active
      limit_lines="$OPTARG"
      ;;
    r)
      # option -r active
      [ -z "${a}" ] || usage
      sort_option="-k1,1n -k2,2r"
      ;;
    a)
      # option -a active
      [ -z "${r}" ] || usage
      sort_option="-k2,2"
      ;;
    n)
      # option -n active
      name_exp="$OPTARG"
      ;;
    *)
      usage
      ;;
  esac
done

# removes options and their associated values,
# allows your script to access and process the non-option arguments
shift $((OPTIND-1))

# LC_ALL=EN_us.utf8 for uniform date
# Eventualmente, verificar se folders não está vazia !!!
# Resolver os erros em, por exemplo, ./spacecheck.sh -n "*.txt" /home/pedro/Documents/Universidade

if [[ $# -eq 1 ]]
then
  [ -d "$1" ] || usage  # check: valid directory
  directory=$1
fi

# Logic of greater or equal: "\( -size '"$s"'c -o -size +'"$s"'c \)"
folders=$(find "$directory" -type d -exec sh -c '
test -n "$(find "$0" -maxdepth 1 -type f -regex "'"$name_exp"'" \( -size '"$size"'c -o -size +'"$size"'c \) -newermt "'"$date_ref"'" )"
' {} \; -print)

if [ -z "$limit_lines" ]; then
  limit_lines=$(echo "$folders" | wc -l)
fi

for f in $folders; do

  bytes=$(find "$f" -maxdepth 1 -newermt "$date_ref" -type f -regex "$name_exp" -exec du -b {} + | awk -v size="$size" '$1 >= size {sum+=$1} END {print sum}')
  echo "$bytes" "$f"

done | sort $sort_option
 #| head -n "$limit_lines"



