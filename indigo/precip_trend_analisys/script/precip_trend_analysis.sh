#!/bin/bash

# Author: CMCC Foundation
# Creation date: 25/08/2016

# This script assumes that UV-CDAT environment is
UVCDATenv=ophidia-nox

# This script assumes that BasePath to store output file for OPeNDAP is
BasePath=$OPH_SCRIPT_DATA_PATH/INDIGO/precip_trend_input

# Input parameters
FileName=${1}
LatRange=${2}
LonRange=${3}
NewGrid=${4}

RelWorkDir="`dirname \"$0\"`"
AbsWorkDir="`( cd \"$RelWorkDir\" && pwd )`"

InputPath=$OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID
OutputPath=$BasePath/$OPH_SCRIPT_SESSION_CODE/$OPH_SCRIPT_WORKFLOW_ID

InFile=$InputPath/$FileName

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
) > $InputPath/.grid
sed -i "s/XSIZE/$XSIZE/g" $InputPath/.grid
sed -i "s/YSIZE/$YSIZE/g" $InputPath/.grid
sed -i "s/XFIRST/$XFIRST/g" $InputPath/.grid
sed -i "s/YFIRST/$YFIRST/g" $InputPath/.grid
sed -i "s/XINC/$XINC/g" $InputPath/.grid
sed -i "s/YINC/$YINC/g" $InputPath/.grid

tmp=$InputPath/.tmp.nc
cdo remapbil,$InputPath/.grid $InFile $tmp
mv $tmp $InFile

rm -f $InputPath/.grid

fi

# Publish output data using OPeNDAP
mkdir -p $OutputPath
cp $InFile $OutputPath/ 2>&1 > /dev/null &

# Create and publish UV-CDAT map
source activate $UVCDATenv
python $AbsWorkDir/precip_trend_analysis.py $AbsWorkDir $InputPath/ $LATS $LONS
source deactivate

cp $InputPath/precip_trend_analysis.png $OutputPath/

exit 0

