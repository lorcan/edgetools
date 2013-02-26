#!/bin/bash

PROGNAME=`basename $0`
verbose=no

function usage () {
  cat <<EOF
Uses the seed list of egos in the seed file to get a subset of the edgelists in the edgelist directory. The merged, sorted edgelist is saved to the outputfile'.
Usage: $PROGNAME [-v] seedlist edgelistdirectory outputfile
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

if [ $# -ne 3 ]; then
  echo "Expected three arguments."
  usage
fi

SEEDFILE=$1
DIRECTORY=$2
OUTPUTFILE=$3

if [ $verbose == 'yes' ]; then
  echo "Building an edgelist from the .csv files in $DIRECTORY."
fi

for file in $DIRECTORY/*.csv
do
  if [ $verbose == 'yes' ]; then
    echo "Gathering edges from the CSV $file into subsets."
  fi
  nice bash -c "python getEdgelist.py $SEEDFILE $file $file.subset" 
done

if [ $verbose == 'yes' ]; then
  echo "Merging the subsets into $OUTPUTFILE."
fi
nice bash -c "sort -m -t, -k1,1 -k2,2 $DIRECTORY/*.subset -o $OUTPUTFILE"

if [ $verbose == 'yes' ]; then
  echo "Removing the temporary subset files from $DIRECTORY."
fi
ls "$DIRECTORY"/*.subset | xargs rm -f {}
