#!/bin/bash

# Author: CMCC Foundation
# Creation date: 02/11/2015

# This script assumes UV-CDAT environment is called 'ophidia-nox'

WorkDir=$1
InFile=$OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/${2}.nc
BasePath=/data/repository/INDIGO/precip_trend_output

# Publish output data using OPeNDAP
mkdir -p $BasePath/$OPH_SCRIPT_SESSION_CODE/$OPH_SCRIPT_WORKFLOW_ID
cp $InFile $BasePath/$OPH_SCRIPT_SESSION_CODE/$OPH_SCRIPT_WORKFLOW_ID/ 2>&1 > /dev/null &

# Create and publish UV-CDAT map
source activate ophidia-nox
python $WorkDir/precip_trend_analysis_ensemble.py $WorkDir $OPH_SCRIPT_SESSION_PATH/$OPH_SCRIPT_WORKFLOW_ID/ $2
source deactivate

exit 0

