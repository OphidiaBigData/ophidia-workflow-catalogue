#!/bin/bash

# CLIPC - GlobSnow
# Attributes

if [ $# -ne 3 ]; then
	exit -1
fi

filepath=$1;		# Path of the file to modify
filename=$2;		# Name of the file to modify
timecoverage=$3;	# Reference time domain

ncatted -O -h -a Conventions,global,o,c,"CF-1.6" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 1
fi
ncatted -O -h -a title,global,o,c,"Snow OFF" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 2
fi
ncatted -O -h -a activity,global,o,c,"Snow OFF" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 3
fi
ncatted -O -h -a product,global,o,c,"ESA-GlobSnow" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 4
fi
ncatted -O -h -a package_name,global,o,c,"Ophidia" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 5
fi
ncatted -O -h -a package_references,global,o,c,"ophidia.cmcc.it" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 6
fi
ncatted -O -h -a references,global,o,c,"ophidia.cmcc.it" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 7
fi
ncatted -O -h -a comment,global,o,c,"First day when Snow Water Equivalent is zero after snow season" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 8
fi
ncatted -O -h -a date_created,global,o,c,"`date +%Y-%m-%d`" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 9
fi
ncatted -O -h -a date_published,global,o,c,"`date +%Y-%m-%d`" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 10
fi
ncatted -O -h -a date_revised,global,o,c,"`date +%Y-%m-%d`" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 11
fi
ncatted -O -h -a keywords,global,o,c,"Snow off" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 12
fi
ncatted -O -h -a institution,global,o,c,"CMCC" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 13
fi
ncatted -O -h -a institution_id,global,o,c,"CMCC" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 14
fi
ncatted -O -h -a institution_url,global,o,c,"www.cmcc.it" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 15
fi
ncatted -O -h -a contact_email,global,o,c,"ophidia-info@cmcc.it" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 16
fi
ncatted -O -h -a creator_name,global,o,c,"CMCC" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 17
fi
ncatted -O -h -a creator_url,global,o,c,"www.cmcc.it" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 18
fi
ncatted -O -h -a creator_email,global,o,c,"ophidia-info@cmcc.it" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 19
fi
ncatted -O -h -a contributor_name,global,o,c," " $filepath/$filename
if [ $? -ne 0 ]; then
        exit 20
fi
ncatted -O -h -a contributor_role,global,o,c," " $filepath/$filename
if [ $? -ne 0 ]; then
        exit 21
fi
ncatted -O -h -a platform,global,o,c,"station" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 22
fi
ncatted -O -h -a platform_id,global,o,c," " $filepath/$filename
if [ $? -ne 0 ]; then
        exit 23
fi
ncatted -O -h -a satellite_algorithm,global,o,c," " $filepath/$filename
if [ $? -ne 0 ]; then
        exit 24
fi
ncatted -O -h -a satellite_sensor,global,o,c,"SSM/I" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 25
fi
ncatted -O -h -a indata_history,global,o,c," " $filepath/$filename
if [ $? -ne 0 ]; then
        exit 26
fi
ncatted -O -h -a frequency,global,o,c,"mon" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 27
fi
starttime=${timecoverage%_*}
ncatted -O -h -a time_coverage_start,global,o,c,"$starttime" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 28
fi
stoptime=${timecoverage##*_}
ncatted -O -h -a time_coverage_end,global,o,c,"$stoptime" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 29
fi
ncatted -O -h -a time_coverage_duration,global,o,c,"365" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 30
fi
ncatted -O -h -a time_coverage_resolution,global,o,c,"day" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 31
fi
ncatted -O -h -a cdm_datatype,global,o,c,"grid" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 32
fi
ncatted -O -h -a domain,global,o,c," " $filepath/$filename
if [ $? -ne 0 ]; then
        exit 33
fi
ncatted -O -h -a geospatial_bounds,global,o,c,"POLYGON (35 -180, 85 -180, 85 180, 35 180)" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 34
fi
ncatted -O -h -a geospatial_lat_min,global,o,f,35 $filepath/$filename
if [ $? -ne 0 ]; then
        exit 35
fi
ncatted -O -h -a geospatial_lat_max,global,o,f,85 $filepath/$filename
if [ $? -ne 0 ]; then
        exit 36
fi
ncatted -O -h -a geospatial_lon_min,global,o,f,-180 $filepath/$filename
if [ $? -ne 0 ]; then
        exit 37
fi
ncatted -O -h -a geospatial_lon_max,global,o,f,180 $filepath/$filename
if [ $? -ne 0 ]; then
        exit 38
fi
ncatted -O -h -a geospatial_lat_resolution,global,o,c,"25 km" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 39
fi
ncatted -O -h -a geospatial_lon_resolution,global,o,c,"25 km" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 40
fi
ncatted -O -h -a history,global,o,c," " $filepath/$filename
if [ $? -ne 0 ]; then
        exit 41
fi
ncatted -O -h -a project_id,global,o,c,"CLIP-C" $filepath/$filename
if [ $? -ne 0 ]; then
        exit 42
fi

exit 0

