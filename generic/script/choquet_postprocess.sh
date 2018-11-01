#!/bin/bash

if [ $# -lt 2 ]; then
	exit -1
fi

input_file=$OPH_SCRIPT_DATA_PATH/$1			# Original file used to 
output_file=$OPH_SCRIPT_DATA_PATH/$2		# File to be adapted

# Copy lat/lon,lambert_azimuthal_equal_area variables from source
ncks -h -A -C -v transverse_mercator $input_file $output_file
if [ $? -ne 0 ]; then
        exit 1
fi

ncatted -O -h -a esri_pe_string,H,d,, $output_file
if [ $? -ne 0 ]; then
        exit 1
fi
ncatted -O -h -a units,H,o,c,"None" $output_file
if [ $? -ne 0 ]; then
        exit 1
fi
ncatted -O -h -a long_name,H,o,c,"Choquet integral" $output_file
if [ $? -ne 0 ]; then
        exit 1
fi
ncatted -O -h -a Source_Software,global,o,c,"Ophidia" $output_file
if [ $? -ne 0 ]; then
        exit 1
fi

# Translation to ASC format
gdal_translate -of AAIGrid $output_file $output_file.asc

exit 0

