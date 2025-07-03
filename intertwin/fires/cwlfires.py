#!/usr/bin/env python

import sys
from pyophidia import Client, Experiment, Workflow #, Cube

# Input parameters
input_folder="/data/fires/@{model}/@{scenario}/@{frequency_&{variable}}/@{variable}/" # "/data/products/ESGF/CMIP6/ScenarioMIP/CMCC/@{model}/@{scenario}/r1i1p1f1/@{frequency_&{variable}}/@{variable}/gn/"
input_format="@{variable}_@{frequency_&{variable}}_@{model}_@{scenario}_r1i1p1f1_gn_*.nc"
lat_range="-90:90"
lon_range="0:360"
time_range="2090-01-01_2090-01-15"
output_folder="/data/fires/output/"
output_format="@{variable}_@{frequency_&{variable}}_@{model}_@{scenario}_r1i1p1f1_gn_" + time_range.replace(':','') + ".nc"
regrid_script="/path/to/regrid.sh"
new_grid="r360x180"
python_script="/path/to/fires.sh"
model_format="@{model}_@{scenario}.nc"
scenario_format="@{operation}_@{scenario}.nc"
fires_index="tos"
display=True

hosts="1"
cores="1"
threads=str(sys.argv[2])
partition="partition"
container="fires"

cli = Client(server=sys.argv[1], read_env=True, project="R000")

#Cube.setclient(cli)
#Cube.cluster(action='deploy',host_partition=partition,nhost=hosts,exec_mode='async')

exp = Experiment.load_cwl("cwl/fires.cwl", "--nthreads " + threads)

print("Workflow validity: " + str(exp.check(display=display)))

Workflow.setclient(cli)
wf = Workflow(exp)
wf.submit()
wf.monitor(frequency=1, iterative=True, display=display)
print("Workflow completed")

#wf.build_provenance("Fires",output_format="json",display=display)

cli.submit("oph_delete cube=[*];exec_mode=async;", display=False)

#Cube.cluster(action='undeploy',host_partition=partition,exec_mode='async')

