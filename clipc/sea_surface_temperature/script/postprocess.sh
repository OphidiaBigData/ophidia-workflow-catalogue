#!/bin/bash

# ESA-CCI-SST

if [ $# -lt 2 ]; then
	exit -1
fi

filepath=$1;		# Path of the file to modify
filename=$2;		# Name of the file to modify

ncatted -h -a geospatial_lon_min,global,o,f,-180 $filepath/$filename
if [ $? -ne 0 ]; then
        exit 1
fi
ncatted -h -a geospatial_vertical_min,global,o,f,-0.2 $filepath/$filename
if [ $? -ne 0 ]; then
        exit 2
fi
ncatted -h -a geospatial_vertical_max,global,o,f,-0.2 $filepath/$filename
if [ $? -ne 0 ]; then
        exit 3
fi
ncatted -h -a _FillValue,analysed_sst,o,s,-32768 $filepath/$filename
if [ $? -ne 0 ]; then
        exit 4
fi
ncatted -h -a missing_value,analysed_sst,o,s,-32768 $filepath/$filename
if [ $? -ne 0 ]; then
        exit 5
fi
ncatted -h -a add_offset,analysed_sst,d,s,273 $filepath/$filename
if [ $? -ne 0 ]; then
        exit 6
fi
ncatted -h -a units,analysed_sst,o,c,"degrees C" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 6
fi

exit 0
