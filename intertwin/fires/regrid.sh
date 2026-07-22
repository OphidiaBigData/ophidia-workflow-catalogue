#!/bin/bash

set -e

# Input parameters
LatRange=${1}
LonRange=${2}
NewGrid=${3}
Variable=${4}
InFile=${5}
OutFile=${6}

FileName=$InFile
TempFile=$InFile.temp
RelWorkDir="`dirname \"$0\"`"
AbsWorkDir="`( cd \"$RelWorkDir\" && pwd )`"

LATS=180
LONS=360

# Python-based regridding
if [ "$NewGrid" == "interp_like" ]; then

rm -f $TempFile
$AbsWorkDir/regrid.py $InFile $TempFile

# CDO-based regridding
elif [ "$NewGrid" != "" ]; then

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

tmp=$FileName.tmp
rm -f $tmp

OUT=0
ncdump -v plev $InFile > /dev/null 2>&1 || OUT=$?
if [ $OUT -eq 0 ]; then
    ncpdq -a time,plev,lat,lon $InFile $tmp
else
    ncpdq -a time,lat,lon $InFile $tmp
fi
rm -f $TempFile
mv $tmp $TempFile

cdo -setctomiss,inf -remapcon,$FileName.grid $TempFile $tmp
rm -f $TempFile
mv $tmp $TempFile

rm -f $FileName.grid

else

if [ "$InFile" != "$OutFile" ]; then
cp $InFile $TempFile
fi

fi

while
    if { set -C; 2>/dev/null >$OutFile.lock; }; then
        trap "rm -f $OutFile.lock" EXIT
    	ncks -A -v $Variable $TempFile $OutFile
        if [ $? != 0 ]; then
            ncks -A -C -v $Variable $TempFile $OutFile
        fi
        ncatted -h -O -a CDO,global,d,, $OutFile
        ncatted -h -O -a NCO,global,d,, $OutFile
        ncatted -h -O -a history_of_appended_files,global,d,, $OutFile
        ncatted -h -O -a history,global,d,, $OutFile
        rm -f $OutFile.*.ncks.tmp
    	rm -f $OutFile.lock
    	break
    else
        sleep 1
    fi
do true; done
rm -f $TempFile

exit 0


