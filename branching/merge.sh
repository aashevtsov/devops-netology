#!/bin/bash
# display command line options

count=1
<<<<<<< HEAD
for param in "$*"; do
    echo "\$* Parameter #$count = $param"
    count=$(( $count + 1 ))
=======
while [[ -n "$1" ]]; do
    echo "Parameter #$count = $1"
    count=$(( $count + 1 ))
    shift
>>>>>>> git-merge
done
