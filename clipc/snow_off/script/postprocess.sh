#!/bin/bash

# CLIPC - GlobSnow

if [ $# -lt 5 ]; then
	exit -1
fi

filepath=$1;		# Path of the file to modify
filename=$2;		# Name of the file to modify
timecoverage=$3;	# Reference time domain
variable=$4		# Name of the measure
setOffset=$5		# Set time offset in measure attributes

# Copy lat/lon,lambert_azimuthal_equal_area variables from source
ncks -h -A -C -v lat,lon,lambert_azimuthal_equal_area /data/repository/CLIPC/GlobSnow_SWE_L3A/GlobSnow_SWE_L3A_20121231_v2.0.nc $filepath/$filename
if [ $? -ne 0 ]; then
        exit 1
fi

# Modify the time coverage global attribute
ncatted -O -h -a time_coverage,global,m,c,"$3" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 3
fi

# Add the measure attributes
ncatted -h -a long_name,$variable,o,c,"$variable" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 6
fi
ncatted -h -a _FillValue,$variable,o,f,-99999 $filepath/$filename
if [ $? -ne 0 ]; then
        exit 6
fi
ncatted -h -a grid_mapping,$variable,o,c,"lambert_azimuthal_equal_area" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 6
fi
ncatted -h -a standard_name,$variable,o,c,"lwe_thickness_of_surface_snow_amount" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 6
fi
if [ $setOffset -gt 0 ]; then
stoptime=${timecoverage##*_}
starttime=${stoptime%-*}
ncatted -h -a units,$variable,o,c,"days since $starttime-01-01 00:00:00" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 6
fi
ncatted -h -a calendar,$variable,o,c,"standard" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 6
fi
else
ncatted -h -a units,$variable,o,c,"d" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 6
fi
fi

# Add the dimension attributes
ncatted -h -a long_name,x,o,c,"x coordinate of projection" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 7
fi
ncatted -h -a units,x,o,c,"m" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 7
fi
ncatted -h -a standard_name,x,o,c,"projection_x_coordinate" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 7
fi
ncatted -h -a long_name,y,o,c,"y coordinate of projection" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 7
fi
ncatted -h -a units,y,o,c,"m" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 7
fi
ncatted -h -a standard_name,y,o,c,"projection_y_coordinate" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 7
fi

exit 0
