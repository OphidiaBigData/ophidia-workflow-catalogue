#!/usr/bin/env python

import sys
from pyophidia import Client, Workflow, Experiment #, Cube

# Input parameters
input_folder = "/data/vorticity/input"
output_folder = "/data/vorticity/output"
output_variable1 = "msl"
output_variable2 = "vo_850"
lat_range = "0:70"
lon_range = "100:320"
plev_name = "plev" # plev or lev (for MPI-ESM1-2-HR)
plev_type = "float" # double or float (for CNRM-CM6-1-HR)
regrid_script = "/path/to/regrid.sh"
merge_script = "/path/to/merge.sh"
new_grid = "r880x280"
display = True
number_of_files = "1"
query_on_files = "*_201*.nc"
init_script = "/path/to/linkinput.sh"

# Costants
hosts = "1"
cores = "1"
threads = str(sys.argv[2])
partition = "partition"
container = "wind"
lon_file = "/data/CMIP6/HighResMIP/CMCC/CMCC-CM2-VHR4/highres-future/r1i1p1f1/6hrPlevPt/psl/gn/v20190509/psl_6hrPlevPt_CMCC-CM2-VHR4_highres-future_r1i1p1f1_gn_201501010000-201501311800.nc"
core_limit = "20"
time_part1 = lon_file.index(lon_file.split("_")[-1]) - 2
time_part2 = time_part1 + 13
eq_ray = "6378137" # m
pol_ray = "6356702" # m
q_ray = "6372797" # m

cli = Client(server = sys.argv[1], read_env = True)
#Cube.setclient(cli)

#Cube.cluster(action = 'deploy',host_partition = partition, nhost = hosts, exec_mode = 'async')

exp = Experiment.load_cwl("vorticity.cwl", "--nthreads " + threads + " --lon_file " + lon_file + " --container " + container + " --lat_range " + lat_range + " --space_range " + lat_range + "|" + lon_range + " --number_of_files " + number_of_files + " --query_on_files " + query_on_files + " --output_variable1 " + output_variable1 + " --output_variable2 " + output_variable2)

print("Workflow validity: " + str(exp.check(display=display)))

Workflow.setclient(cli)
wf = Workflow(exp)
wf.submit()
wf.monitor(frequency = 1, iterative = True, display = display)
print("Workflow completed")

#wf.build_provenance("Vorticity",output_format="json",display=display)

#Cube.cluster(action = 'undeploy', host_partition = partition, exec_mode = 'async')

cli.submit("oph_delete cube=[*]", display=False)

