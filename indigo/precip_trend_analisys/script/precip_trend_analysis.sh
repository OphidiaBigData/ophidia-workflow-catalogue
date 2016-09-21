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
InFile=$OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/$FileName

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
) > $OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/.grid
sed -i "s/XSIZE/$XSIZE/g" $OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/.grid
sed -i "s/YSIZE/$YSIZE/g" $OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/.grid
sed -i "s/XFIRST/$XFIRST/g" $OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/.grid
sed -i "s/YFIRST/$YFIRST/g" $OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/.grid
sed -i "s/XINC/$XINC/g" $OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/.grid
sed -i "s/YINC/$YINC/g" $OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/.grid

tmp=$OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/.tmp.nc
cdo remapbil,$OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/.grid $InFile $tmp
mv $tmp $InFile

rm -f $OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/.grid

fi

# Publish output data using OPeNDAP
mkdir -p $BasePath/$OPH_SCRIPT_SESSION_CODE/$OPH_SCRIPT_WORKFLOW_ID
cp $InFile $BasePath/$OPH_SCRIPT_SESSION_CODE/$OPH_SCRIPT_WORKFLOW_ID/ 2>&1 > /dev/null &

# Create and publish UV-CDAT map
source activate $UVCDATenv
python $AbsWorkDir/precip_trend_analysis.py $AbsWorkDir $OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/ $LATS $LONS
source deactivate

cp $OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/precip_trend_analysis.png $BasePath/$OPH_SCRIPT_SESSION_CODE/$OPH_SCRIPT_WORKFLOW_ID/

exit 0

