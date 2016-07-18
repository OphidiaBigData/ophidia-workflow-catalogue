#!/bin/bash

# Author: CMCC Foundation
# Creation date: 02/11/2015

ophidia_server_prefix=/var/www/html/ophidia/sessions
opendap_prefix=/data/repository/INDIGO/precip_trend_output

cube=$1		
filename=${cube##*/}	
filename_without_extension=${filename%.*}
path_without_filename=${cube%/*}
id_job=${path_without_filename##*/}
temp2=${path_without_filename%/*}
id_workflow=${temp2##*/}
temp3=${temp2%/*}
temp4=${temp3%/*}
temp5=${temp4%/*}
id_session=${temp5##*/}

mkdir -p $opendap_prefix/$id_session/$id_workflow
cp $ophidia_server_prefix/$id_session/export/nc/$id_workflow/$id_job/$filename $opendap_prefix/$id_session/$id_workflow/

