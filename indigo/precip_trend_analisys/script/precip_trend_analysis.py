# Author: CMCC Foundation
# Creation date: 24/07/2016

import vcs
import cdms2
import numpy
import sys

# Parse input parameters
# It is assumed sys.argv[0] is the filename 'precip_trend_analysis.py'

WorkDir = sys.argv[1]
ViridisScript = "/".join([WorkDir, "viridis.json"])

DataDir = sys.argv[2]
InFile = "/".join([DataDir, "precip_trend_analysis.nc"])
OutFile = "/".join([DataDir, "precip_trend_analysis.png"])

Lats = sys.argv[3]

Lons = sys.argv[4]

# Process file

f = cdms2.open(InFile)

pr = f("precip_trend")

x = vcs.init()
vcs.scriptrun(ViridisScript)

colormapname = "bl_to_darkred"
# colormapname = "viridis"
x.setcolormap(colormapname)

iso = x.createisofill()

number_different_colors = 64
levels = numpy.arange(-3., 3.00001, 6. / float(number_different_colors + 1)).tolist()
iso.levels = levels

cols = vcs.getcolors(levels, split=0)

iso.fillareacolors = cols
iso.legend = vcs.mklabels(numpy.arange(-3, 3.01, .375))

# Now create a template to move things around a bit
t = x.createtemplate()
t.xmintic1.priority = 1  # turn on bottom sub ticks
t.xmintic2.priority = 1  # turn on top sub ticks
t.ymintic1.priority = 1  # turn on left sub ticks
t.ymintic2.priority = 1  # turn on right sub ticks

if Lons < 1.2*Lats:
	t.scale(.9 * Lons / (2 * Lats), "x")
	t.scale(1.5, "y")
elif Lons < 2*Lats:
	t.scale(.9, "x")
	t.scale(1.8 * Lats / Lons, "y")
else:
	t.scale(.9, "x")
	t.scale(.9, "y")
t.moveto(.05, .1)

# Move legend
t.legend.x1 = t.data.x2 + .03
t.legend.x2 = t.legend.x1 + .03
t.legend.y1 = t.data.y1 + .05
t.legend.y2 = t.data.y2 - .05
t.legend.textorientation = "left"

# Move units
t.units.x = t.data.x2
t.units.y = t.data.y2 + .02
t.units.textorientation = "right"

# Move "small title"
t.title.x = t.data.x1
t.title.y = t.data.y2 + .02
t.title.textorientation = "left"

# Big title
txt = x.createtext()
txt.x = [(t.data.x1 + t.data.x2) / 2.]
txt.y = .9
txt.string = ["Precipitation Trend"]
txt.height = 15
txt.halign = "center"

# Making axes names prettier than lat/lon
pr.getLatitude().id="Latitude"
pr.getLongitude().id="Longitude"

# Turn off a few things
t.blank(["xname", "yname", "mean", "min", "max", "dataname"])

x.plot(pr, iso, t)

x.plot(txt)

x.png(OutFile)


