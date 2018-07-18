#!/bin/bash

# Author: CMCC Foundation
# Creation date: 05/07/2018

if [ $# -lt 5 ]
then
        echo "Wrong number of arguments"
        exit 1
fi

/usr/local/ophidia/oph-terminal/bin/oph_term -H ${OPH_SCRIPT_SERVER_HOST} -P ${OPH_SCRIPT_SERVER_PORT} -u ${OPH_SCRIPT_USER} -p $1 -e "precip_trend_analysis.json $2 $3 $4 $5"

exit 0

