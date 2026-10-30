#!/bin/bash
mydir=./sample_home
mkdir -p "$mydir"
printf 'sample\n' > "$mydir/readme.txt"
if [ -d "$mydir" ]
then
    echo "The $mydir directory exists"
    cd "$mydir" || exit 1
    ls
else
    echo "The $mydir directory does not exist"
fi
