#!/bin/bash

# Author: CMCC Foundation
# Creation date: 06/11/2017

# Input parameters
DataPath=$OPH_SCRIPT_DATA_PATH/${1}
InFile=$DataPath/${2}
LatRange=${3}
LonRange=${4}
NewGrid=${5}

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
) > $DataPath/.grid
sed -i "s/XSIZE/$XSIZE/g" $DataPath/.grid
sed -i "s/YSIZE/$YSIZE/g" $DataPath/.grid
sed -i "s/XFIRST/$XFIRST/g" $DataPath/.grid
sed -i "s/YFIRST/$YFIRST/g" $DataPath/.grid
sed -i "s/XINC/$XINC/g" $DataPath/.grid
sed -i "s/YINC/$YINC/g" $DataPath/.grid

tmp=$DataPath/.tmp.nc
cdo remapbil,$DataPath/.grid $InFile $tmp
mv $tmp $InFile

rm -f $DataPath/.grid

fi

exit 0


