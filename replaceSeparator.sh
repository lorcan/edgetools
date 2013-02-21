#!/bin/bash

progname=$0
verbose=no

function usage () {
   cat <<EOF
Processes a directory of edgelists and replaces the separator charactor with a comma. This is done in a dumb fashion.
Usage: $progname [-v] separator directory
   -v   executes and prints out verbose messages
   -h   displays basic help
EOF
        exit 0
}

while getopts ":vhn:" optname; do
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
        echo "Expected two arguments. Got $#"
        usage
fi

SEPARATOR=$1
DIRECTORY=$2

for file in $DIRECTORY/*
do
  echo "Converting $file"
  nice sed "s/$SEPARATOR/,/g" $file >> $file.csv &
done
