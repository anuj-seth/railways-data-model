#!/usr/bin/env bash
pguser=$1
pgdb=$2
pgpassword=$3

for f in `ls 0*.sh`
do
    # print in red and then switch off colors
    echo -e "\033[0;31mRunning ${f}\033[0m"
    ./$f $pguser $pgdb $pgpassword
done
