#!/bin/bash
# Error message: stdout -> stderr
usage() { echo "Usage: $0 [-d <date>] [-s <size>] [-l <limit>] [-r | -a] [-n <regex>] [<directory>]" 1>&2; exit 1; }

sort="-k1,1nr" # default sort

# getopts to parse command-line options
while getopts "d:s:l:ran::" opt; do
  case "$opt" in
    d)
      # option -d active
      d=${OPTARG}
      date_ref=$(LC_TIME=en_US.utf8 date -d "$d" "+%Y-%m-%d %H:%M:%S")
      ;;
    s)
      # option -s active
      s=${OPTARG}
      ;;
    l)
      # option -l active
      l=${OPTARG}
      ;;
    r)
      # option -r active
      [ -z "${a}" ] || usage
      sort="-k1,1n -k2,2r"
      r=true
      ;;
    a)
      # option -a active
      [ -z "${r}" ] || usage
      a=true
      sort="-k2,2"
      ;;
    n)
      # option -n active
      n=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done

# removes options and their associated values,
# allows your script to access and process the non-option arguments
shift $((OPTIND-1))

if [[ $# -eq 1 ]]
then
  [ -d "$1" ] || usage  # check: valid directory
  directory=$1
else
  directory="."
fi


# Eventualmente, verificar se folders não está vazia !!!
# Resolver os erros em, por exemplo, ./spacecheck.sh -n "*.txt" /home/pedro/Documents/Universidade


if [ -z "$s" ]; then
  s=0
else
  [[ $s -eq "0" ]] || s=$((s-1))
fi

# LC_ALL=EN_us.utf8 for uniform date
# Eventualmente, verificar se folders não está vazia !!!
# Resolver os erros em, por exemplo, ./spacecheck.sh -n "*.txt" /home/pedro/Documents/Universidade

if [ -z "$d" ]; then
    date_ref="0000-01-01 00:00:00"
fi

folders=$(find "$directory" -type d -exec sh -c '
test -n "$(find "$0" -maxdepth 1 -type f -name "'"$n"'" -size +"'"$s"'"c -newermt "'"$date_ref"'" )"
' {} \; -print)

if [ -z "$l" ]; then
  l=$(echo "$folders" | wc -l)
fi


for f in $folders; do
  numero_bytes=$(find "$f" -maxdepth 1 -newermt "$date_ref" -type f -name "$n" -exec du -b {} + | awk -v size="$s" '$1 >= size {sum+=$1} END {print sum}')

  echo $numero_bytes $f

done | sort $sort | head -n "$l"



