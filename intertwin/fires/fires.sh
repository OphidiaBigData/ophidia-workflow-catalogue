#!/bin/bash

set -e

echo "Python script"

InputFile=$1
OutputFile=$2

mv $InputFile $InputFile.input

echo "Start download a sample file to be regridded and renamed: $OutputFile"
curl -k -s -o $InputFile https://www.unidata.ucar.edu/software/netcdf/examples/tos_O1_2001-2002.nc
echo "Download of $InputFile completed"

LATS=180
LONS=360

# Bilinear regridding
NewGrid="r360x180"
FileName=$InputFile

XSIZE=${NewGrid%%x*}
XSIZE=${XSIZE##*r}
YSIZE=${NewGrid##*x}
XFIRST=${LonRange%%:*}
YFIRST=${LatRange%%:*}
XLAST=${LonRange##*:}
YLAST=${LatRange##*:}
LATS=`echo "($YLAST)-($YFIRST)" | bc -l`
LONS=`echo "($XLAST)-($XFIRST)" | bc -l`
XINC=`echo "($LONS)/($XSIZE)" | bc -l`
YINC=`echo "($LATS)/($YSIZE)" | bc -l`
XFIRST=`echo "($XFIRST)+0.5" | bc -l`
YFIRST=`echo "($YFIRST)+0.5" | bc -l`

(
cat <<'EOF'
gridtype = lonlat
xsize = XSIZE
ysize = YSIZE
xfirst = XFIRST
xinc = XINC
yfirst = YFIRST
yinc = YINC
EOF
) > $FileName.grid
sed -i "s/XSIZE/$XSIZE/g" $FileName.grid
sed -i "s/YSIZE/$YSIZE/g" $FileName.grid
sed -i "s/XFIRST/$XFIRST/g" $FileName.grid
sed -i "s/YFIRST/$YFIRST/g" $FileName.grid
sed -i "s/XINC/$XINC/g" $FileName.grid
sed -i "s/YINC/$YINC/g" $FileName.grid

cdo remapcon,$FileName.grid $InputFile $OutputFile
rm -f $FileName.grid

echo "Regridding of $OutputFile completed"

exit 0
