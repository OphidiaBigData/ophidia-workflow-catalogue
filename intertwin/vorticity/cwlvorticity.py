#!/usr/bin/env python

import sys
from pyophidia import Client, Experiment, Workflow #, Cube

# Input parameters
input_folder="/data/vorticity/input"
output_folder="/data/vorticity/output"
lat_range="0:70"
lon_range="100:320"
regrid_script="/path/to/regrid.sh"
new_grid="r880x280"
lon_file="/data/vorticity/input/psl_6hrPlevPt_CMCC-CM2-VHR4_highresSST-future_r1i1p1f1_gn_201502010000-201502010600.nc"
display=False

hosts="1"
cores="1"
threads=str(sys.argv[2])
partition="partition"
container="wind"

cli = Client(server=sys.argv[1], read_env=True, project="R000")

#Cube.setclient(cli)
#Cube.cluster(action='deploy',host_partition=partition,nhost=hosts,exec_mode='async')

exp = Experiment.load_cwl("cwl/vorticity.cwl", "--nthreads " + threads)

print("Workflow validity: " + str(exp.check(display=display)))

Workflow.setclient(cli)
wf = Workflow(exp)
wf.submit()
wf.monitor(frequency=1, iterative=True, display=display)
print("Workflow completed")

#wf.build_provenance("Vorticity",output_format="json",display=display)

cli.submit("oph_delete cube=[*];exec_mode=async;", display=False)

#Cube.cluster(action='undeploy',host_partition=partition,exec_mode='async')

