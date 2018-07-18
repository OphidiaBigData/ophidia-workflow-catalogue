#!/bin/bash

# Author: CMCC Foundation
# Creation date: 05/07/2018

# This script assumes that UV-CDAT environment is
UVCDATenv=ophidia-nox

# This script assumes that BasePath to store output file for OPeNDAP is
BasePath=$OPH_SCRIPT_DATA_PATH/ensemble_analysis

# Input parameters
FileNameWithoutExtension=${1}

RelWorkDir="`dirname \"$0\"`"
AbsWorkDir="`( cd \"$RelWorkDir\" && pwd )`"

DataPath=$BasePath/$OPH_SCRIPT_SESSION_CODE/$OPH_SCRIPT_WORKFLOW_ID
InFile=$DataPath/$FileNameWithoutExtension.nc

# Create and publish UV-CDAT map
UVCDATpath=/usr/local/ophidia/extra/miniconda3/bin
export HOME=/gfs-data/home/`whoami`
source $UVCDATpath/activate $UVCDATenv
echo "no" | python $AbsWorkDir/ensemble_analysis.py $AbsWorkDir $DataPath/ $FileNameWithoutExtension
source $UVCDATpath/deactivate $UVCDATenv

exit 0

