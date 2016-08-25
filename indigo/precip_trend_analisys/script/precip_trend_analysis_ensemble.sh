#!/bin/bash

# Author: CMCC Foundation
# Creation date: 02/11/2015

# This script assumes that UV-CDAT environment is
UVCDATenv=ophidia-nox

# This script assumes that BasePath to store output file for OPeNDAP is
BasePath=/data/repository/INDIGO/precip_trend_output

# Input parameters
WorkDir=$1
InFile=$OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/${2}.nc

# Publish output data using OPeNDAP
mkdir -p $BasePath/$OPH_SCRIPT_SESSION_CODE/$OPH_SCRIPT_WORKFLOW_ID
cp $InFile $BasePath/$OPH_SCRIPT_SESSION_CODE/$OPH_SCRIPT_WORKFLOW_ID/ 2>&1 > /dev/null &

# Create and publish UV-CDAT map
source activate $UVCDATenv
python $WorkDir/precip_trend_analysis_ensemble.py $WorkDir $OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/ $2
source deactivate

exit 0

