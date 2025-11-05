#!/usr/bin/env python

import sys
import numpy as np
import xarray as xr

input_path = sys.argv[1]
output_path = sys.argv[2]

data = np.arange(180 * 360).reshape(180, 360)
r = range(-90, 90)
lat = [x + 0.5 for x in r]
r = range(0, 360)
lon = [x + 0.5 for x in r]
ds_sf = xr.DataArray(
    data=data,
    dims=["lat", "lon"],
    coords=dict(
        lon=lon,
        lat=lat,
    )
)

ds_var = xr.open_dataset(input_path)
ds_var = ds_var.interp_like(ds_sf)
ds_var.to_netcdf(output_path)


