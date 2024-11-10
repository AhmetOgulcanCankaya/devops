#!/bin/bash

help(){
    echo "Help is on the way!"
    echo ""
    echo "To use simply run: ./options.sh -[abch]"
    echo "-h help (prints this)"
    echo "-a algorithm list, comma seperated values."
    echo "-b binary tree name, single string"
    echo "-c counts, simple number"
}

ALGORITHMS=""
BINARY_TREE_NAME=""
COUNT=0

while getopts 'a:b:c:h' opt; do
  case "$opt" in
    a)
      echo "Processing option 'a'"
      ALGORITHMS=$OPTARG
      ;;

    b)
      echo "Processing option 'b'"
      BINARY_TREE_NAME=$OPTARG
      ;;

    c)
      COUNT="$OPTARG"
      echo "Processing option 'c' with '${OPTARG}' argument"
      ;;
    :)
       echo -e "option requires an argument.\nUsage: $(basename $0) [-a arg] [-b arg] [-c arg] [-h]"
       exit 1
       ;;
    ?)
      echo "Usage: $(basename $0) [-a] [-b] [-c arg]"
      exit 1
      ;;
    h)
        help
        exit;;
  esac
done
shift "$(($OPTIND -1))"

echo "ALGORITHMS=${ALGORITHMS}"
echo "BINARY_TREE_NAME=${BINARY_TREE_NAME}"
echo "COUNT=${COUNT}"