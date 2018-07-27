
# coding: utf-8

# COMPUTE DTR, Daily temperature range: Monthly mean difference between TX and TN

# In[ ]:

from PyOphidia import cube
cube.Cube.setclient(read_env=True)


# Import Tasmin and Tasmax variables

# In[ ]:

tasmax = cube.Cube(
    src_path='/data/ecas_training/tasmax_day_CMCC-CESM_rcp85_r1i1p1_20960101-21001231.nc',
    measure='tasmax',
    imp_dim='time',
    import_metadata='yes',
    imp_concept_level='d',
    ncores=4,
    description='Max Temperatures',
    hierarchy='oph_base|oph_base|oph_time',
    vocabulary='CF'
    )


# In[ ]:

tasmin = cube.Cube(
    src_path='/data/ecas_training/tasmin_day_CMCC-CESM_rcp85_r1i1p1_20960101-21001231.nc',
    measure='tasmin',
    imp_dim='time',
    import_metadata='yes',
    imp_concept_level='d',
    ncores=4,
    description='Min Temperatures',
    hierarchy='oph_base|oph_base|oph_time',
    vocabulary='CF'
    )


# Compute daily DTR

# In[ ]:

dailyDTR = tasmax.intercube(
    cube2=tasmin.pid,
    operation='sub',
    description="Daily DTR",
    ncores=4
    )


# Compute monthly DTR

# In[ ]:

monthlyDTR = dailyDTR.reduce2(
    dim='time',
    concept_level='M',
    operation='avg',
    description="Monthly DTR",
    ncores=4    
)


# Extract the first month (Jan 2096)

# In[ ]:

firstMonthDTR = monthlyDTR.subset2(
    subset_dims='time',
    subset_filter='2096-01',
    description="Subset Monthly DTR",
    ncores = 4
)

data = firstMonthDTR.export_array()


# Plot monthly DTR

# In[ ]:

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

clevs = np.arange(0,20,1)

cnplot = map.contourf(x,y,var,clevs,cmap=plt.cm.jet)
cbar = map.colorbar(cnplot,location='right')

plt.title('DTR (deg K)')
plt.show()


# In[ ]:



