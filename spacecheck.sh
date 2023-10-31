#!/bin/bash
#
# Visualization of occupied space by directories and specifications

# Error message: stdout -> stderr
usage() { echo "Usage: $0 [-d <date>] [-s <size>] [-l <limit>] [-r | -a] [-n <regex>] [<directory>]" 1>&2; exit 1; }
argError() { echo "ALERT: \"$1\" arg is invalid." 1>&2; exit 1; }
nothingFound() { echo "ERROR: nothing was found." 1>&2; exit 1; }
invalidDirectory() { echo "ERROR: \"$1\" directory is invalid." 1>&2; exit 1; }

# --------------------------------------
# Defaults
# --------------------------------------
header="$*"

directories="."
sort_option="-k1,1nr" # default sort
size=0
name_exp=".*" 
date_ref=$(LC_TIME=en_US.utf8 date "+%Y-%m-%d %H:%M:%S")
# --------------------------------------
# --------------------------------------


# getopts to parse command-line options
while getopts "d:s:l:ran::" opt 2>/dev/null; do
  case "$opt" in
    d)
      # option -d active
      # -d "    " - print the current date
      date_ref=$(LC_TIME=en_US.utf8 date -d "$OPTARG" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
      [[ $? -ne 0 ]] || [[ -z "$OPTARG" ]] && argError "-d"
      # se for 0 ou se for nulo dá o tempo
      ;;
    s)
      # option -s active
      [ -z "$OPTARG" ] && argError "-s"
      if [[ "$OPTARG" -ge 0 ]]; then
        size="$OPTARG"
        [[ $size =~ ^[0-9]+$ ]] || argError "-s"
      else
        argError "-s"
      fi
      ;;
    l)
      # option -l active
      [ -z "$OPTARG" ] && argError "-l"
      if [[ "$OPTARG" -gt 0 ]]; then
        limit_lines="$OPTARG"
      else
        argError "-l"
      fi
      ;;
    r)
      # option -r active
      [[ "$sort_option" = "-k1,1nr" ]] || usage
      sort_option="-k1,1n -k1,1r -k2,2r"
      ;;
    a)
      # option -a active
      [[ "$sort_option" = "-k1,1nr" ]] || usage
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

if [[ $# -ge 1 ]]
then
  directories=""
  for dir in "$@"; do
    [ -d "$dir" ] || invalidDirectory "$dir" # check: valid directory
    [ "$dir" = "/" ] || [ "$dir" = "//" ] || dir=$(echo "$dir" | sed 's:/*$::')
    directories="${directories}$dir "
  done
fi

# all folders in directory
folders=$(find $directories -type d 2>/dev/null | sort -u)

[ -z "$folders" ] && nothingFound

if [ -z "$limit_lines" ]; then
  limit_lines=$(echo "$folders" | wc -l)
fi

# header
echo "SIZE NAME $(LC_TIME=en_US.utf8 date "+%Y%m%d") $header"

while IFS= read -r f; do

  if [ -x "$f" ]; then
    bytes=$(find "$f" -not -newermt "$date_ref" -type f -regex "$name_exp" -not -size -"$size"c  -exec du -bc {} + 2>/dev/null | tail -n 1 | awk '{print $1}')
    [ -z "$bytes" ] && bytes=0
    echo "$bytes" "$f"
  else
    echo "NA" "$f"
  fi

done <<< "$folders" | sort "$sort_option" | head -n "$limit_lines"

