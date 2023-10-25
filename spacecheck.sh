#!/bin/bash
source ./validation/spacecheck_validation.sh

# Error message: stdout -> stderr
usage() { echo "Usage: $0 [-d <date>] [-s <size>] [-l <limit>] [-r | -a] [-n <regex>] [<directory>]" 1>&2; exit 1; }


# --------------------------------------
# Defaults
# --------------------------------------
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
      if [[ -n "$OPTARG" ]]; then
        date_ref=$(LC_TIME=en_US.utf8 date -d "$OPTARG" "+%Y-%m-%d %H:%M:%S")
      elif [[ "$OPTARG" == "\"" ]]; then
        echo "ERRO! The date is invalid!"
        usage
      else
        echo "ERRO! The date is invalid!"
        usage
      fi
      ;;
    s)
      # option -s active
      if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
        size="$OPTARG"
      else
        echo "ERRO! The size is invalid!"
        usage
      fi
      ;;
    l)
      # option -l active
      if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
        limit_lines="$OPTARG"
      else
        echo "ERRO! The limit lines is invalid!"
        usage
      fi
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

# header
echo "SIZE NAME $(date "+%Y%m%d") $*"

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

done | sort $sort_option | head -n "$limit_lines"



