#!/usr/bin/env python

import sys
from pyophidia import Cube, Client, Workflow, Experiment

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

exp = Experiment(name="Vorticity",
                author="CMCC",
                abstract="This workflow evaluate the wind vorticity dv/dlon - du/dlat given the wind components u and v using PyOphidia",
                exec_mode="sync",
#                host_partition=partition,
                nthreads=threads,
                on_exit="oph_delete",
                ncores=cores)

t1 = exp.newTask(name="Create a work container",
                operator="oph_createcontainer",
                on_error="skip",
                arguments={"container": container, "dim": "time|plev|lat|lon"})

t2 = exp.newTask(name="Get latitude",
                operator="oph_importnc2",
                arguments={"imp_dim": "lat", "measure": "lat", "input": lon_file, "container": container, "nfrag": "1", "subset_dims": "lat", "subset_filter": lat_range, "subset_type": "coord"},
                dependencies={t1:''})

t3 = exp.newTask(name="Evaluate latitude factor",
                operator="oph_apply",
                arguments={"query": "oph_matheval('oph_double','oph_float',measure,'cos(pi*x/180)')"},
                dependencies={t2:'cube'})

t4 = exp.newTask(name="Iterate on time",
                operator="oph_for",
                arguments={"parallel": "yes", "key": "source", "input": "[" + input_folder + "/psl_*.nc]"})

tp1 = exp.newTask(name="Import PSL",
                operator="oph_importnc2",
                arguments={"imp_dim": "lat", "measure": "psl", "input": "@source", "container": container, "nfrag": threads, "subset_dims": "lat|lon", "subset_filter": lat_range + "|" + lon_range, "subset_type": "coord"},
                dependencies={t1:'', t4:''})

tp2 = exp.newTask(name="Export PSL",
                operator="oph_exportnc2",
                arguments={"output": output_folder + "/@{source_file}"},
                dependencies={tp1:'cube'})

tp3 = exp.newTask(name="Regrid PSL",
                operator="oph_script",
                arguments={"script": regrid_script, "args": output_folder + "/@{source_file} " + lat_range + " " + lon_range + " " + new_grid},
                dependencies={tp2:''})

tu1 = exp.newTask(name="Import U",
                operator="oph_importnc2",
                arguments={"imp_dim": "lat", "measure": "ua", "input": "@{source_path}/ua_@{source_file+4}", "container": container, "nfrag": threads, "subset_dims": "plev|lat|lon", "subset_filter": "85000|" + lat_range + "|" + lon_range, "subset_type": "coord"},
                dependencies={t1:'', t4:''})

tu2 = exp.newTask(name="Evaluate du/dlat",
                operator="oph_apply",
                arguments={"query": "oph_matheval(oph_gsl_spline(measure,dimension,dimension,1),'180*x/(6372507*pi)')", "measure_type": "auto"},
                dependencies={tu1:'cube'})

tu3 = exp.newTask(name="Rollup U",
                operator="oph_rollup",
                arguments={},
                dependencies={tu2:'cube'})

tu4 = exp.newTask(name="Permute U",
                operator="oph_permute",
                arguments={"dim_pos": "2,1"},
                dependencies={tu3:'cube'})

tv1 = exp.newTask(name="Import V",
                operator="oph_importnc2",
                arguments={"imp_dim": "lon", "measure": "va", "input": "@{source_path}/va_@{source_file+4}", "container": container, "nfrag": threads, "subset_dims": "plev|lat|lon", "subset_filter": "85000|" + lat_range + "|" + lon_range, "subset_type": "coord"},
                dependencies={t1:'', t4:''})

tv2 = exp.newTask(name="Evaluate dv/dlon",
                operator="oph_apply",
                arguments={"query": "oph_matheval(oph_gsl_spline(measure,dimension,dimension,1),'180*x/(6372507*pi)')", "measure_type": "auto"},
                dependencies={tv1:'cube'})

tv3 = exp.newTask(name="Rollup V",
                operator="oph_rollup",
                arguments={},
                dependencies={tv2:'cube'})

tv4 = exp.newTask(name="Put latitude factor",
                operator="oph_intercube", 
                arguments={ "operation": "div", "cube2_is_array": "yes", "extension_type": "interlace" },
                dependencies={tv3:'cube', t3:'cube2'})

t4 = exp.newTask(name="Evaluate vorticity",
                operator="oph_intercube", 
                arguments={ "measure": "rv850" },
                dependencies={tv4:'cube', tu4:'cube2'})

t5 = exp.newTask(name="Delete metadata",
                operator="oph_metadata", 
                arguments={ "mode": "delete", "variable": "rv850", "metadata_key": "comment" },
                dependencies={t4:'cube'})

t6 = exp.newTask(name="Update metadata",
                operator="oph_metadata", 
                arguments={ "mode": "update", "variable": "rv850", "metadata_key": "standard_name|long_name|units", "metadata_value": "atmosphere_relative_vorticity|Vorticity (relative)|s**-1", "force": "yes" },
                dependencies={t5:'cube'})

t7 = exp.newTask(name="Export VO",
                operator="oph_exportnc2",
                arguments={"output": output_folder + "/vo_@{source_file+4}"},
                dependencies={t6:'cube'})

t8 = exp.newTask(name="Regrid VO",
                operator="oph_script",
                arguments={"script": regrid_script, "args": output_folder + "/vo_@{source_file+4} " + lat_range + " " + lon_range + " " + new_grid},
                dependencies={t7:''})

t9 = exp.newTask(name="End iteration",
                operator="oph_endfor",
                arguments={},
                dependencies={tp3:'', t8:''})

print("Workflow validity: " + str(exp.check(display=display)))

Workflow.setclient(cli)
wf = Workflow(exp)
wf.submit()
wf.monitor(frequency=1, iterative=True, display=display)
print("Workflow completed")

#wf.build_provenance("Vorticity",output_format="json",display=display)

#Cube.cluster(action='undeploy',host_partition=partition,exec_mode='async')

