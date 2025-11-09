#!/usr/bin/env python

import sys
from pyophidia import Client, Experiment, Workflow #, Cube

# Input configurations
scenarios = "ssp126" # "ssp126|ssp245|ssp370|ssp585"
models = "CMCC-ESM2|NorESM2-MM" # "CMCC-ESM2|NorESM2-MM|CESM2|MPI-ESM1-2-HR"
institutes = "CMCC|NCC" # "CMCC|NCC|NCAR|MPI-M"
variables = "lai|tas|hur|tasmin|pr|sftlf" # "lai|tas|hur|tasmin|pr|sftlf"
measures = "lai|lst_day|rel_hum|t2m_min|pr|lsm" # "lai|lst_day|rel_hum|t2m_min|pr|lsm"
frequencies = "Eday|day|day|day|day|fx" # "Eday|day|day|day|day|fx"

# Input parameters
input_folder="/data/fires/@{model}/@{scenario}/@{frequency_&{variable}}/@{variable}/"
base_format="@{variable}_@{frequency_&{variable}}_@{model}_@{scenario}_r1i1p1f1_gn"
input_format=base_format + "*.nc"
lat_range="-90:90"
lon_range="0:360"
time_range = "2030-01-01_2031-01-01"
output_folder="/data/fires/output/"
output_format=base_format + "_" + time_range.replace(':','') + ".nc"
clear_script = "/path/to/clear.sh"
regrid_script="/path/to/regrid.sh"
new_grid="r360x180"
python_script="/path/to/inference.sh"
model_format="@{model}_@{scenario}.nc"
inference_format = "inferenced_@{model}_@{scenario}.nc"
scenario_format="@{operation}_@{scenario}.nc"
fires_index="global_burned_areas"
display=True
mask_file = "/data/fires/mask.nc"

# Costants
hosts="1"
cores="1"
threads=str(sys.argv[2])
partition="partition"
container="fires"

cli = Client(server = sys.argv[1], read_env = True)
#Cube.setclient(cli)

#Cube.cluster(action = 'deploy', host_partition = partition, nhost = hosts, exec_mode = 'async')

exp = Experiment.load_cwl("fires.cwl", "--nthreads " + threads + " --container " + container + " --time_range " + time_range)

print("Workflow validity: " + str(exp.check(display = display)))

Workflow.setclient(cli)
wf = Workflow(exp)
wf.submit()
wf.monitor(frequency = 1, iterative = True, display = display)
print("Workflow completed")

#wf.build_provenance("Fires", output_format = "json", display = display)

#Cube.cluster(action = 'undeploy', host_partition = partition, exec_mode = 'async')

cli.submit("oph_delete cube=[*]", display = False)

