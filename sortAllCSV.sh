#!/bin/bash

PROGNAME=`basename $0`
verbose=no

function usage () {
  cat <<EOF
Takes each csv file in a directory and sorts it according to its first column.'.
Usage: $PROGNAME [-v] directory
   -v   executes and prints out verbose messages
   -h   displays basic help
EOF
  exit 0
}

while getopts ":vh" optname; do
  case "$optname" in
    v)
      verbose=yes
      ;;
    h)
      usage
      ;;
    ?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
    *)
      # Should not occur
      echo "Unknown error while processing options"
      ;;
  esac
done

shift $(($OPTIND - 1))

if [ $# -ne 1 ]; then
  echo "Expected one argument."
  usage
fi

DIRECTORY=$1
if [ $verbose == 'yes' ]; then
  echo "Sorting all .csv files in $DIRECTORY alphabetically by their first column and then by their second columns"
fi

for file in $DIRECTORY/*.csv; do
  if [ $verbose == 'yes' ]; then
    echo "Sorting CSV $file."
  fi
  nice bash -c "sort -t, -k1,1 -k2,2 $file -o $file"
  if [ $verbose == 'yes' ]; then
    echo "CSV $file sorted."
  fi
done

