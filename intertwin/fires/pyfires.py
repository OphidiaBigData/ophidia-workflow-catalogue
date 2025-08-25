#!/usr/bin/env python

import sys
from pyophidia import Client, Experiment, Workflow #, Cube

# Input configurations
scenarios = "ssp126" # "ssp126|ssp245|ssp370|ssp585"
models = "CMCC-ESM2|NorESM2-MM"
institutes = "CMCC|NCC"
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
clear_script = "/data/fires/clear.sh"
regrid_script="/data/fires/regrid.sh"
new_grid="r360x180"
python_script="/data/fires/inference.py"
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

exp = Experiment(name="Fires",
                author="CMCC",
                abstract="This workflow evaluate the fire metrics given the datasets of several scenarios and models using PyOphidia",
                exec_mode="sync",
#                host_partition=partition,
                on_exit="oph_delete",
                nthreads=threads,
                ncores=cores)

ti1 = exp.newTask(name="Init frequency",
                operator="oph_set",
                arguments={"key": "frequency", "value": frequencies})

ti2 = exp.newTask(name="Init measure",
                operator="oph_set",
                arguments={"key": "measure", "value": measures})

ti3 = exp.newTask(name="Init institutes",
                operator="oph_set",
                arguments={"key": "institute", "value": institutes})

ti4 = exp.newTask(name="Clear output folder",
                operator="oph_generic",
                on_error="skip",
                arguments={"command": clear_script, "input": output_folder, "output": "null"},
                dependencies={ti1:'', ti2:'', ti3:''})

tc = exp.newTask(name="Create a work container",
                operator="oph_createcontainer",
                on_error="skip",
                arguments={"container": container, "dim": "time|plev|lat|lon", "hierarchy": "oph_time|oph_base|oph_base|oph_base"},
                dependencies={ti4:''})

tmask = exp.newTask(name="Import mask",
                operator="oph_importnc2",
                arguments={"imp_dim": "time", "measure": "basis_regions", "src_path": mask_file, "container": container, "nfrag": threads},
                dependencies={tc:''})

tf1 = exp.newTask(name="Iterate on scenarios",
                operator="oph_for",
                arguments={"parallel": "yes", "key": "scenario", "values": scenarios},
                dependencies={tc:''})

tf2 = exp.newTask(name="Iterate on models",
                operator="oph_for",
                arguments={"parallel": "yes", "key": "model", "values": models},
                dependencies={tf1:''})

tf3 = exp.newTask(name="Iterate on variables",
                operator="oph_for",
                arguments={"parallel": "yes", "key": "variable", "values": variables},
                dependencies={tf2:''})

tp1a = exp.newTask(name="Check for reduction operation",
                operator="oph_if",
                arguments={"condition": "&{variable}-6"}, # Set a condition to be 0 only in case the variable is "sftlf"
                dependencies={tf3:''})

tp1b1 = exp.newTask(name="Check for selection operation",
                operator="oph_if",
                arguments={"condition": "&{variable}-3"}, # Set a condition to be 0 only in case the variable is "hur"
                dependencies={tp1a:''})

tp1b2 = exp.newTask(name="Import variable",
                operator="oph_importncs",
                arguments={"imp_dim": "time", "measure": "@variable", "src_path": input_folder + input_format, "container": container, "nfrag": threads, "subset_dims": "time", "subset_filter": time_range, "subset_type": "coord"},
                dependencies={tp1b1:''})

tp1b3 = exp.newTask(name="Else selection",
                operator="oph_else",
                arguments={},
                dependencies={tp1b1:''})

tp1b4 = exp.newTask(name="Import hur",
                operator="oph_importncs",
                arguments={"imp_dim": "time", "measure": "@variable", "src_path": input_folder + input_format, "container": container, "nfrag": threads, "subset_dims": "plev|time", "subset_filter": "1|" + time_range, "subset_type": "index|coord"},
                dependencies={tp1b3:''})

tp1b5 = exp.newTask(name="End check selection",
                operator="oph_endif",
                arguments={},
                dependencies={tp1b2:'cube', tp1b4:'cube'})

tp1c = exp.newTask(name="Reduction on octets",
                operator="oph_reduce2",
                arguments={"operation": "median", "concept_level": "o"},
                dependencies={tp1b5:'cube'})

tp1d = exp.newTask(name="Else reduction",
                operator="oph_else",
                arguments={},
                dependencies={tp1a:''})

tp1e = exp.newTask(name="Import sftlf",
                operator="oph_importncs", # oph_importnc2 cannot be used since the src_path contains an '*' to avoid to consider the dataset version 
                arguments={"measure": "@variable", "src_path": input_folder + input_format.replace('*',''), "container": container, "nfrag": "1"},
                dependencies={tp1d:''})

tp1f = exp.newTask(name="End check reduction",
                operator="oph_endif",
                arguments={},
                dependencies={tp1c:'cube', tp1e:'cube'})

tp2 = exp.newTask(name="Rename measure",
                operator="oph_apply",
                arguments={"measure": "@{measure_&{variable}}"},
                dependencies={tp1f:'cube'})

tp3 = exp.newTask(name="Export variable",
                operator="oph_exportnc2",
                arguments={"output": output_folder + output_format},
                dependencies={tp2:'cube'})

tp4 = exp.newTask(name="Regrid variable",
                operator="oph_generic",
                arguments={"command": regrid_script, "output": output_folder + "regridded_" + model_format, "args": lat_range + " " + lon_range + " " + new_grid + " @{measure_&{variable}}"},
                dependencies={tp3:'input'})

te3 = exp.newTask(name="End iteration on variables",
                operator="oph_endfor",
                arguments={},
                dependencies={tp4:''})

tm0 = exp.newTask(name="Infer data",
                operator="oph_generic",
                arguments={"command": python_script, "input": output_folder + "regridded_" + model_format, "output": output_folder + "fires_" + model_format, "args": fires_index},
                dependencies={te3:''})

tm1 = exp.newTask(name="Import model",
                operator="oph_importnc2",
                arguments={"imp_dim": "time", "measure": fires_index, "container": container, "nfrag": threads, "imp_concept_level": "o"},
                dependencies={tm0:'input'})

tm2 = exp.newTask(name="Reduction on years",
                operator="oph_reduce2",
                arguments={"operation": "avg", "concept_level": "y"},
                dependencies={tm1:'cube'})

tm3 = exp.newTask(name="Apply the mask",
                operator="oph_intercube", 
                arguments={ "operation": "mul", "extension_type": "append" },
                dependencies={tm2:'cube', tmask:'cube2'})

tm4 = exp.newTask(name="Export model",
                operator="oph_exportnc2",
                arguments={"output": output_folder + inference_format},
                dependencies={tm3:'cube'})

te2 = exp.newTask(name="End iteration on models",
                operator="oph_endfor",
                arguments={},
                dependencies={tm3:'cube', tm4:''})

tm5 = exp.newTask(name="Merge models",
                operator="oph_mergecubes2",
                arguments={"dim": "ensemble"},
                dependencies={te2:'cubes'})

tf4 = exp.newTask(name="Iterate on ensemble operations",
                operator="oph_for",
                arguments={"parallel": "yes", "key": "operation", "values": "avg|min|max|var|std"},
                dependencies={tm5:'cube'})

tm6 = exp.newTask(name="Ensemble operation",
                operator="oph_reduce2",
                arguments={"operation": "@{operation}", "dim": "ensemble"},
                dependencies={tf4:'cube'})

tm7 = exp.newTask(name="Export scenario",
                operator="oph_exportnc2",
                arguments={"output": output_folder + scenario_format},
                dependencies={tm6:'cube'})

te4 = exp.newTask(name="End iteration on ensemble operations",
                operator="oph_endfor",
                arguments={},
                dependencies={tm7:''})

te1 = exp.newTask(name="End iteration on scenarios",
                operator="oph_endfor",
                arguments={},
                dependencies={te4:''})

tcd = exp.newTask(name="Destroy the work container",
                operator="oph_deletecontainer",
                on_error="skip",
                arguments={"container": container, "force": "yes"},
                dependencies={te1:''})

print("Workflow validity: " + str(exp.check(display = display)))

Workflow.setclient(cli)
wf = Workflow(exp)
wf.submit()
wf.monitor(frequency = 1, iterative = True, display = display)
print("Workflow completed")

#wf.build_provenance("Fires", output_format = "json", display = display)

#Cube.cluster(action = 'undeploy', host_partition = partition, exec_mode = 'async')

cli.submit("oph_delete cube=[*]", display = False)

