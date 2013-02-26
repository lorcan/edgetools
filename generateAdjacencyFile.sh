#!/bin/bash

PROGNAME=`basename $0`
verbose=no

function usage () {
  cat <<EOF
Takes each csv file in a directory and extracts the list of adjacency pairs within them. These lists are merged into the outputfile. Adjacency is calculated based on the first two columns of the csv file.
Usage: $PROGNAME [-v] directory outputfile
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

if [ $# -ne 2 ]
then
        echo "Expected two arguments."
        usage
fi

DIRECTORY=$1
OUTPUTFILE=$2

if [ $verbose == 'yes' ]; then
  echo "Generating neighbour file $OUTPUTFILE based on the contents of all .csv files in $DIRECTORY"
fi

for file in $DIRECTORY/*.csv; do
  if [ $verbose == 'yes' ]; then
    echo "Extracting neighbour pairs from $file into $file.neighbours"
  fi
  nice bash -c "cat $file | sed 's/^\([^,]*\),\([^,]*\),.*$/\1,\2\n\2,\1/' | sort -u -t, -k1,1 -k2,2 -o '$file'.neighbours" 
done

if [ $verbose == 'yes' ]; then
  echo "Merging neighbour pair files into $OUTPUTFILE"
fi
nice bash -c "sort -u -t, -k1,1 -k2,2 -o $OUTPUTFILE -m $DIRECTORY/*.neighbours"

if [ $verbose == 'yes' ]; then
  echo "Removing temporary neighbour files in $DIRECTORY."
fi
rm "$DIRECTORY"/*.neighbours

