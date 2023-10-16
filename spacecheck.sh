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
fi

# Tests

echo "d = ${d}"
echo "s = ${s}"
echo "l = ${l}"
echo "r = ${r}"
echo "a = ${a}"
echo "n = ${n}"
echo "directory = ${directory}"




if [ -n "$directory" ]; then
  total_bits=0

  while IFS= read -r -d '' file; do
    file_size=$(stat -c "%s" "$file") # file size in bytes
    total_bits=$((total_bits + file_size))
  done < <(find "$directory" -type f -name "*.sh" -print0)
fi

echo "$total_bits"