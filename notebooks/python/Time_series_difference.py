
# coding: utf-8

# Import PyOphidia and connect to server instance

# In[ ]:

from PyOphidia import cube, client
cube.Cube.setclient(read_env=True)


# Import data, compute difference between a time series from 2nd year and one from 1st year, and get output

# In[ ]:

mycube = cube.Cube.importnc(src_path='/public/data/tos_O1_2001-2002.nc',measure='tos',imp_dim='time',ncores=5)
firstYear = mycube.subset2(subset_dims="lat|lon|time",subset_filter="0:1|0:1|0:365",ncores=5)
secondYear = mycube.subset2(subset_dims="lat|lon|time",subset_filter="0:1|0:1|366:730",ncores=5)
diff = secondYear.intercube(cube2=firstYear.pid)
data = diff.export_array()


# Plot time series difference

# In[ ]:

import matplotlib.pyplot as plt
y = data['measure'][0]['values'][0][:]
x = data['dimension'][2]['values'][:]
plt.figure(figsize=(11, 5), dpi=100)
plt.bar(x, y)

plt.ylabel(data['measure'][0]['name'] + " (degK)")
plt.title('Sea Surface Temperature - difference 2002-2001  (point 0.5, 1)')
plt.xticks(x, ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'], rotation='vertical')
plt.show()

