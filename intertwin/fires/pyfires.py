#!/usr/bin/env python

import sys
from pyophidia import Client, Experiment, Workflow #, Cube

# Input parameters
input_folder="/data/fires/@{model}/@{scenario}/@{variable}/" # "/data/products/ESGF/CMIP6/ScenarioMIP/CMCC/@model/@scenario/r1i1p1f1/day/@variable/gn/"
input_format="@{variable}_day_@{model}_@{scenario}_r1i1p1f1_gn_*.nc"
lat_range="-90:90"
lon_range="0:360"
time_range="2090-01-01_2090-01-15"
output_folder="/data/fires/output/"
output_format="@{variable}_day_@{model}_@{scenario}_r1i1p1f1_gn_" + time_range.replace(':','') + ".nc"
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

exp = Experiment(name="Fires",
                author="CMCC",
                abstract="This workflow evaluate the fire metrics given the datasets of several scenarios and models using PyOphidia",
                exec_mode="sync",
#                host_partition=partition,
                on_exit="oph_delete",
                nthreads=threads,
                ncores=cores)

tc = exp.newTask(name="Create a work container",
                operator="oph_createcontainer",
                on_error="skip",
                arguments={"container": container, "dim": "time|lat|lon", "hierarchy": "oph_time|oph_base|oph_base"})

tf1 = exp.newTask(name="Iterate on scenarios",
                operator="oph_for",
                arguments={"parallel": "yes", "key": "scenario", "values": "ssp126"}) # "ssp126|ssp245|ssp370|ssp585"

tf2 = exp.newTask(name="Iterate on models",
                operator="oph_for",
                arguments={"parallel": "yes", "key": "model", "values": "CMCC-ESM2"}, # "CMCC-CM2-SR5|CMCC-ESM2"
                dependencies={tf1:''})

tf3 = exp.newTask(name="Iterate on variables",
                operator="oph_for",
                arguments={"parallel": "yes", "key": "variable", "values": "pr"}, # "lai|tas|hur|tasmin|pr|sftlf"
                dependencies={tf2:''})

tp1 = exp.newTask(name="Import variable",
                operator="oph_importncs",
                arguments={"imp_dim": "time", "measure": "@variable", "src_path": input_folder + input_format, "container": container, "nfrag": threads, "subset_dims": "time", "subset_filter": time_range, "subset_type": "coord"},
                dependencies={tc:'', tf3:''})

tp2 = exp.newTask(name="Reduction on octets",
                operator="oph_reduce2",
                arguments={"operation": "median", "concept_level": "o"},
                dependencies={tp1:'cube'})

tp3 = exp.newTask(name="Export variable",
                operator="oph_exportnc2",
                arguments={"output": output_folder + output_format},
                dependencies={tp2:'cube'})

tp4 = exp.newTask(name="Regrid variable",
                operator="oph_script",
                arguments={"script": regrid_script, "args": output_folder + output_format + " " + lat_range + " " + lon_range + " " + new_grid},
                dependencies={tp3:''})

te3 = exp.newTask(name="End iteration on variables",
                operator="oph_endfor",
                arguments={},
                dependencies={tp4:''})

tm0 = exp.newTask(name="Python script",
                operator="oph_script",
                arguments={"script": python_script, "args": output_folder + " @model @scenario " + fires_index},
                dependencies={te3:''})

tm1 = exp.newTask(name="Import model",
                operator="oph_importnc2",
                arguments={"imp_dim": "time", "measure": fires_index, "input": output_folder + model_format, "container": container, "nfrag": threads, "imp_concept_level": "o"},
                dependencies={tc:'', tm0:''})

tm2 = exp.newTask(name="Reduction on years",
                operator="oph_reduce2",
                arguments={"operation": "avg", "concept_level": "y"},
                dependencies={tm1:'cube'})

te2 = exp.newTask(name="End iteration on models",
                operator="oph_endfor",
                arguments={},
                dependencies={tm2:'cube'})

tm3 = exp.newTask(name="Merge models",
                operator="oph_mergecubes2",
                arguments={"dim": "ensemble"},
                dependencies={te2:'cubes'})

tf4 = exp.newTask(name="Iterate on ensemble operations",
                operator="oph_for",
                arguments={"parallel": "yes", "key": "operation", "values": "avg|min|max|var|std"},
                dependencies={tm3:'cube'})

tm5 = exp.newTask(name="Ensemble operation",
                operator="oph_reduce2",
                arguments={"operation": "@{operation}", "dim": "ensemble"},
                dependencies={tf4:'cube'})

tm6 = exp.newTask(name="Export scenario",
                operator="oph_exportnc2",
                arguments={"output": output_folder + scenario_format},
                dependencies={tm5:'cube'})

te4 = exp.newTask(name="End iteration on ensemble operations",
                operator="oph_endfor",
                arguments={},
                dependencies={tm6:''})

te1 = exp.newTask(name="End iteration on scenarios",
                operator="oph_endfor",
                arguments={},
                dependencies={te4:''})

print("Workflow validity: " + str(exp.check(display=display)))

Workflow.setclient(cli)
wf = Workflow(exp)
wf.submit()
wf.monitor(frequency=1, iterative=True, display=display)
print("Workflow completed")

#wf.build_provenance("Fires",output_format="json",display=display)

#Cube.cluster(action='undeploy',host_partition=partition,exec_mode='async')

