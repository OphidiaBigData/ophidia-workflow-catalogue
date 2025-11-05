#!/bin/bash

set -e

N=${1} # Number of file
Query=${2} # Filter on files (e.g. on time)

target=/data/vorticity/input
cd $target
rm -f $target/*

for variable in psl ua va; do
    source=/data/CMIP6/HighResMIP/CMCC/CMCC-CM2-VHR4/highres-future/r1i1p1f1/6hrPlevPt/$variable/gn/v20190509
    cd $source
    i=0
    for file in $Query; do
        ln -s $source/$file $target/$file
        echo "Found and linked: $file"
        let "i+=1"
        if [[ "$i" -ge "$N" ]]; then
            break
        fi
    done
done

exit 0
