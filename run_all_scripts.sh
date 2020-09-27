#!/usr/bin/env bash
pguser=$1
pgdb=$2
pgpassword=$3

for f in `ls 0*.sh`
do
    ./$f $pguser $pgdb $pgpassword
done
