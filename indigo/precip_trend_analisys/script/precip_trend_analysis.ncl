; Author: CMCC Foundation
; Creation date: 02/11/2015

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

	cdf_file = addfile(infile,"r")

	lat = cdf_file->lat
	lon = cdf_file->lon
	pr = cdf_file->precip_trend(:,:)

	wks_type = "png"
	wks_type@wkWidth = 1500
	wks_type@wkHeight = 1000
	xwks = gsn_open_wks(wks_type,outfile)

	resources			= True					; Indicate you want to set some resources.
	resources@tiMainString		= "Precipitation Trend Analysis"	; Create a title.
;	resources@tiXAxisString		= lon@long_name
;	resources@tiYAxisString		= lat@long_name
	resources@sfXArray		= lon
	resources@sfYArray		= lat
	resources@gsnMaximize		= True   
	resources@cnMonoLineColor	= False					; Turn off the drawing of contours lines in one color.
	resources@gsnAddCyclic		= False
	resources@mpMinLatF		= min(lat)				; Zoom in on map.
	resources@mpMaxLatF		= max(lat)
	resources@mpMinLonF		= min(lon)
	resources@mpMaxLonF		= max(lon)
	resources@mpCenterLonF		= 180
        resources@cnFillOn              = True

	resources@lbOrientation		= "vertical"
	resources@cnLevelSelectionMode	= "ManualLevels"
	resources@cnMinLevelValF	= -3
	resources@cnMaxLevelValF	= 3
	resources@cnLevelSpacingF	= 0.125
	resources@lbBoxLinesOn		= False

	plot = gsn_csm_contour_map(xwks,pr,resources)				; Draw a contour plot.

end

