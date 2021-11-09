#!/bin/bash
# display command line options

count=1
<<<<<<< HEAD
for param in "$@"; do
    echo "Next parameter: $param"
    count=$(( $count + 1 ))
done

echo "====="
=======
for param in "$*"; do
    echo "\$* Parameter #$count = $param"
    count=$(( $count + 1 ))
done
>>>>>>> git-merge
