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

InputPath=$OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID
OutputPath=$BasePath/$OPH_SCRIPT_SESSION_CODE/$OPH_SCRIPT_WORKFLOW_ID

InFile=$InputPath/$FileNameWithoutExtension.nc

# Publish output data using OPeNDAP
mkdir -p $OutputPath
cp $InFile $OutputPath/ 2>&1 > /dev/null &

# Create and publish UV-CDAT map
source activate $UVCDATenv
python $AbsWorkDir/precip_trend_analysis_ensemble.py $AbsWorkDir $InputPath/ $FileNameWithoutExtension
source deactivate

exit 0

