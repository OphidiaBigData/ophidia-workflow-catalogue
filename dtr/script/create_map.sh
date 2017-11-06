#!/bin/bash

# Author: CMCC Foundation
# Creation date: 06/11/2017

# This script assumes that UV-CDAT environment is
UVCDATenv=ophidia-nox

# Input parameters
DataPath=$OPH_SCRIPT_DATA_PATH/${1}
FileNameWithoutExtension=${2}
Measure=${3}

RelWorkDir="`dirname \"$0\"`"
AbsWorkDir="`( cd \"$RelWorkDir\" && pwd )`"

# Create and publish UV-CDAT map
source activate $UVCDATenv
python $AbsWorkDir/ensemble.py $AbsWorkDir $DataPath/ $FileNameWithoutExtension $Measure
source deactivate $UVCDATenv

exit 0

