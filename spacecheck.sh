#!/bin/bash
# Error message: stdout -> stderr
usage() { echo "Usage: $0 [-d <date>] [-s <size>] [-l <limit>] [-r | -a] [-n <regex>] [<directory>]" 1>&2; exit 1; }

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
      r=true
      ;;
    a)
      # option -a active
      [ -z "${r}" ] || usage
      a=true
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

folders=$(find "$directory" -type f -name "*.sh" -exec dirname {} \;)

for f in $folders; do
  numero_bits=$(find "$f" -maxdepth 1 -type f -name "*.sh" -exec du -c {} + | awk 'END {print $1}')
  echo "$f"
  array[$f]=$numero_bits
  echo $numero_bits
done


# find sop/praticas/aula1 -maxdepth 1 -type f -name "*.sh" -exec du -c {} +
# find "sop" -type f -name "*.sh" -exec dirname {} \;



