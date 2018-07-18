
# coding: utf-8

# This notebook computes the Tropical Nights index: starting from the daily minimum temperature (2096-2100) TN,
# the Tropical Nights index is the number of days where TN > T (T is  a reference temperature, e.g. 20°C)

# Connect to the remote Ophidia instance

# In[ ]:

from PyOphidia import cube
cube.Cube.setclient(read_env=True)


# Import source data (minimum temperature K)

# In[ ]:

mintemp = cube.Cube(src_path='/data/ecas_training/tasmin_day_CMCC-CESM_rcp85_r1i1p1_20960101-21001231.nc',
    measure='tasmin',
    import_metadata='yes',
    imp_dim='time',
    imp_concept_level='d', vocabulary='CF',hierarchy='oph_base|oph_base|oph_time',
    ncores=4,
    description='Min Temps'
    )


# Identify the tropical nights

# In[ ]:

tropicalnights = mintemp.apply(
    query="oph_predicate('OPH_FLOAT','OPH_INT',measure,'x-298.15','>0','1','0')"
)


# Count the number of tropical nights

# In[ ]:

count = tropicalnights.reduce2(
    operation='sum',
    dim='time',
    concept_level='y',
)


# Plot the result

# In[ ]:

firstyear = count.subset(subset_filter=1, subset_dims='time')


# In[ ]:

data = firstyear.export_array(show_time='yes')
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap, cm
import numpy as np

lat = data['dimension'][0]['values'][:]
lon = data['dimension'][1]['values'][:]
var = data['measure'][0]['values'][:]
var = np.reshape(var, (len(lat), len(lon)))

fig = plt.figure(figsize=(15, 15), dpi=100)
ax  = fig.add_axes([0.1,0.1,0.8,0.8])

map = Basemap(projection='cyl',llcrnrlat= -90,urcrnrlat= 90, llcrnrlon=0,urcrnrlon=360, resolution='c')

map.drawcoastlines()
map.drawparallels(np.arange( -90, 90,30),labels=[1,0,0,0])
map.drawmeridians(np.arange(-180,180,30),labels=[0,0,0,1])

x, y = map(*np.meshgrid(lon,lat))

clevs = np.arange(0,371,10)

cnplot = map.contourf(x,y,var,clevs,cmap=plt.cm.jet)
cbar = map.colorbar(cnplot,location='right')

plt.title('Tropical Nights (year 2096)')
plt.show()


# In[ ]:



