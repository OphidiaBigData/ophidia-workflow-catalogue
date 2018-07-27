
# coding: utf-8

# Import PyOphidia and connect to server instance

# In[ ]:

from PyOphidia import cube, client
cube.Cube.setclient(read_env=True)


# Import data, subset over space and time, compute average over time and extract values

# In[ ]:

mycube = cube.Cube.importnc(src_path='/public/data/tos_O1_2001-2002.nc',measure='tos',imp_dim='time',ncores=5)
mycube2 = mycube.subset2(subset_dims="lat|lon|time",subset_filter="-80:30|30:120|0:30",ncores=5)
mycube3 = mycube2.reduce(operation='max',ncores=5)
mycube4 = mycube3.rollup()
data = mycube4.export_array()


# Plot output on map

# In[ ]:

import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap, cm
import numpy as np

lat = data['dimension'][0]['values'][:]
lon = data['dimension'][1]['values'][:]
var = data['measure'][0]['values'][:]

fig = plt.figure(figsize=(15, 15), dpi=100)
ax  = fig.add_axes([0.1,0.1,0.8,0.8])

map = Basemap(projection='cyl',llcrnrlat= -90,urcrnrlat= 90, llcrnrlon=0,urcrnrlon=360, resolution='c')

map.drawcoastlines()
map.drawparallels(np.arange( -90, 90,30),labels=[1,0,0,0])
map.drawmeridians(np.arange(-180,180,30),labels=[0,0,0,1])

x, y = map(*np.meshgrid(lon,lat))

cnplot = map.contourf(x,y,var,np.arange(273,305,0.5),cmap=plt.cm.jet)
cbar = map.colorbar(cnplot,location='right',format='%.6f')

plt.title('Sea Surface Temperature (deg K)')
plt.show()

