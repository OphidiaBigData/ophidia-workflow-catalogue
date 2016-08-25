#!/bin/bash

# Author: CMCC Foundation
# Creation date: 25/08/2016

# This script assumes that UV-CDAT environment is
UVCDATenv=ophidia-nox

# This script assumes that BasePath to store output file for OPeNDAP is
BasePath=$OPH_SCRIPT_DATA_PATH/INDIGO/precip_trend_output

# Input parameters
FileNameWithoutExtension=${1}

RelWorkDir="`dirname \"$0\"`"
AbsWorkDir="`( cd \"$RelWorkDir\" && pwd )`"
InFile=$OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/$FileNameWithoutExtension.nc

# Publish output data using OPeNDAP
mkdir -p $BasePath/$OPH_SCRIPT_SESSION_CODE/$OPH_SCRIPT_WORKFLOW_ID
cp $InFile $BasePath/$OPH_SCRIPT_SESSION_CODE/$OPH_SCRIPT_WORKFLOW_ID/ 2>&1 > /dev/null &

# Create and publish UV-CDAT map
source activate $UVCDATenv
python $AbsWorkDir/precip_trend_analysis_ensemble.py $AbsWorkDir $OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/ $FileNameWithoutExtension
source deactivate

exit 0

