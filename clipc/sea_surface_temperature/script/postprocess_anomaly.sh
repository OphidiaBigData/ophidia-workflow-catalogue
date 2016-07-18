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
ncatted -h -a _FillValue,anomaly_sst,c,s,-32768 $filepath/$filename
if [ $? -ne 0 ]; then
        exit 4
fi
ncatted -h -a missing_value,anomaly_sst,c,s,-32768 $filepath/$filename
if [ $? -ne 0 ]; then
        exit 5
fi
ncatted -h -a standard_name,anomaly_sst,c,c,"surface_temperature_anomaly" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 6
fi
ncatted -h -a long_name,anomaly_sst,c,c,"anomaly sea surface temperature" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 7
fi
ncatted -h -a units,anomaly_sst,c,c,"degrees C" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 8
fi
ncatted -h -a depth,anomaly_sst,c,c,"20 cm" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 9
fi
ncatted -h -a scale_factor,anomaly_sst,c,f,0.01 $filepath/$filename
if [ $? -ne 0 ]; then
        exit 10
fi

exit 0

