#!/bin/bash

# CLIPC - ESA-GlobSnow
# Long term monthly average

if [ $# -ne 3 ]; then
	exit -1
fi

filepath=$1;	# Path of the file to modify
filename=$2;	# Name of the file to modify
month=$3;	# Prefix of the month

cwd='./time'	#Set this path on the time.nc filepath, usually the same of this script

# Copy lat/lon,lambert_azimuthal_equal_area variables from source
ncks -h -A -C -v lat,lon,lambert_azimuthal_equal_area /data/repository/CLIPC/ESA-GlobSnow-all/source/ESA-GlobSnow-L3B-SWE-monthly-200802-fv2.0.nc $filepath/$filename
if [ $? -ne 0 ]; then
        exit 1
fi

# Copy time,time_bnds from a pre-generated time.nc file
ncks -h -A -C -v time,time_bnds $cwd/time_$month.nc $filepath/$filename
if [ $? -ne 0 ]; then
        exit 2
fi

# Modify the time coverage global attribute
ncatted -O -h -a time_coverage_start,global,m,c,"197910" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 3
fi
ncatted -O -h -a time_coverage_end,global,m,c,"200806" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 4
fi

# Erase nco_openmp_thread_number global attribute
ncatted -h -a nco_openmp_thread_number,global,d,, $filepath/$filename
if [ $? -ne 0 ]; then
        exit 5
fi

# Add the measure attributes
ncatted -h -a long_name,SWE_avg,o,c,"Snow Water Equivalent, monthly aggregate value" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 6
fi
ncatted -h -a _FillValue,SWE_avg,o,f,-99999 $filepath/$filename
if [ $? -ne 0 ]; then
        exit 6
fi
ncatted -h -a grid_mapping,SWE_avg,o,c,"lambert_azimuthal_equal_area" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 6
fi
ncatted -h -a units,SWE_avg,o,c,"mm" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 6
fi
ncatted -h -a standard_name,SWE_avg,o,c,"lwe_thickness_of_surface_snow_amount" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 6
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

