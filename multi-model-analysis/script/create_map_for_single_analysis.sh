#!/bin/bash

# Author: CMCC Foundation
# Creation date: 05/07/2018

# This script assumes that UV-CDAT environment is
UVCDATenv=ophidia-nox

# This script assumes that BasePath to store output file for OPeNDAP is
BasePath=$OPH_SCRIPT_DATA_PATH/single_analysis

# Input parameters
FileName=${1}
LatRange=${2}
LonRange=${3}
NewGrid=${4}

RelWorkDir="`dirname \"$0\"`"
AbsWorkDir="`( cd \"$RelWorkDir\" && pwd )`"

DataPath=$BasePath/$OPH_SCRIPT_SESSION_CODE/$OPH_SCRIPT_WORKFLOW_ID
InFile=$DataPath/$FileName

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

FILEGRID=$DataPath/.grid_$FileName

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
) > $FILEGRID
sed -i "s/XSIZE/$XSIZE/g" $FILEGRID
sed -i "s/YSIZE/$YSIZE/g" $FILEGRID
sed -i "s/XFIRST/$XFIRST/g" $FILEGRID
sed -i "s/YFIRST/$YFIRST/g" $FILEGRID
sed -i "s/XINC/$XINC/g" $FILEGRID
sed -i "s/YINC/$YINC/g" $FILEGRID

tmp=$DataPath/.tmp_$FileName
/usr/local/ophidia/extra/bin/cdo remapbil,$FILEGRID $InFile $tmp
mv $tmp $InFile

rm -f $FILEGRID

fi

# Create and publish UV-CDAT map
UVCDATpath=/usr/local/ophidia/extra/miniconda3/bin
export HOME=/gfs-data/home/`whoami`
source $UVCDATpath/activate $UVCDATenv
echo "no" | python $AbsWorkDir/single_analysis.py $AbsWorkDir $DataPath/ $LATS $LONS
source $UVCDATpath/deactivate $UVCDATenv

exit 0

