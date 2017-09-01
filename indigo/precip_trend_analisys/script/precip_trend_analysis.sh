#!/bin/bash

# Author: CMCC Foundation
# Creation date: 25/08/2016

# This script assumes that UV-CDAT environment is
UVCDATenv=ophidia-nox

# This script assumes that BasePath to store output file for OPeNDAP is
BasePath=$OPH_SCRIPT_DATA_PATH/INDIGO/precip_trend_input

# This script assumes that input and output file should be stored at
DataPath=$BasePath/$OPH_SCRIPT_SESSION_CODE/$OPH_SCRIPT_WORKFLOW_ID

# Input parameters
FileName=${1}
LatRange=${2}
LonRange=${3}
NewGrid=${4}

RelWorkDir="`dirname \"$0\"`"
AbsWorkDir="`( cd \"$RelWorkDir\" && pwd )`"

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

# Create and publish UV-CDAT map
source activate $UVCDATenv
python $AbsWorkDir/precip_trend_analysis.py $AbsWorkDir $DataPath/ $LATS $LONS
source deactivate

exit 0

