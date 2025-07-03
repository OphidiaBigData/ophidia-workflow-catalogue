#!/bin/bash

set -e

# Input parameters
FileName=${1}
LatRange=${2}
LonRange=${3}
NewGrid=${4}

RelWorkDir="`dirname \"$0\"`"
AbsWorkDir="`( cd \"$RelWorkDir\" && pwd )`"

InFile=$FileName

LATS=180
LONS=360

# Bilinear regridding
if [ "$NewGrid" != "" ]; then

XSIZE=${NewGrid%%x*}
XSIZE=${XSIZE##*r}
YSIZE=${NewGrid##*x}
XFIRST=${LonRange%%:*}
YFIRST=${LatRange%%:*}
XLAST=${LonRange##*:}
YLAST=${LatRange##*:}
LATS=`echo "($YLAST)-($YFIRST)" | bc -l`
LONS=`echo "($XLAST)-($XFIRST)" | bc -l`
XINC=`echo "($LONS)/($XSIZE)" | bc -l`
YINC=`echo "($LATS)/($YSIZE)" | bc -l`
let XSIZE+=1
let YSIZE+=1

(
cat <<'EOF'
gridtype = lonlat
xsize = XSIZE
ysize = YSIZE
xfirst = XFIRST
xinc = XINC
yfirst = YFIRST
yinc = YINC
EOF
) > $FileName.grid
sed -i "s/XSIZE/$XSIZE/g" $FileName.grid
sed -i "s/YSIZE/$YSIZE/g" $FileName.grid
sed -i "s/XFIRST/$XFIRST/g" $FileName.grid
sed -i "s/YFIRST/$YFIRST/g" $FileName.grid
sed -i "s/XINC/$XINC/g" $FileName.grid
sed -i "s/YINC/$YINC/g" $FileName.grid

tmp=$FileName.tmp

OUT=0
ncdump -v plev $InFile > /dev/null 2>&1 || OUT=$?
if [ $OUT -eq 0 ]; then
    ncpdq -a time,plev,lat,lon $InFile $tmp
else
    ncpdq -a time,lat,lon $InFile $tmp
fi
mv $tmp $InFile

cdo remapcon,$FileName.grid $InFile $tmp
mv $tmp $InFile

rm -f $FileName.grid

fi

exit 0

