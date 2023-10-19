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
      sort="-k1,1n"
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

# Tests

#echo "d = ${d}"
#echo "s = ${s}"
#echo "l = ${l}"
#echo "r = ${r}"
#echo "a = ${a}"
#echo "n = ${n}"
#echo "directory = ${directory}"
#

declare -A array

# Eventualmente, verificar se folders não está vazia !!!
# Resolver os erros em, por exemplo, ./spacecheck.sh -n "*.txt" /home/pedro/Documents/Universidade

  folders=$(find "$directory" -type d -exec sh -c 'test -n "$(find "$0" -maxdepth 1 -type f -name "'"$n"'" -size +15c )"' {} \; -print)

if [ -z "$l" ]; then
  l=$(echo "$folders" | wc -l)
fi


for f in $folders; do
  numero_bits=$(find "$f" -maxdepth 1 -type f -name "$n" -exec du -b {} + | awk '$1 > 15 {sum+=$1} END {print sum}')
  #numero_bits=$(find "$f" -maxdepth 1 -type f -name "$n" -exec du -bc {} + | awk 'END {print $1}')
  echo $numero_bits $f
done | sort $sort | head -n "$l"



