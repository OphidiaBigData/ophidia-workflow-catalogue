#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: This workflow evaluate the wind vorticity dv/dlon - du/dlat given the wind components u and v using PyOphidia

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  inputexperiment:
    type: File?
  nthreads: int

outputs:
  outputexperiment:
    type: File
    outputSource: End_iteration/experiment

steps:
  Create_a_work_container:
    run: tasks/createcontainer.cwl
    in:
      experiment: inputexperiment
      name: 
        default: "Create a work container"
      container:
        default: "wind"
      dim:
        default: "time|plev|lat|lon"
      on_error:
        default: "skip"
    out: [experiment]

  Get_latitude:
    run: tasks/importnc2.cwl
    in:
      experiment: Create_a_work_container/experiment
      name:
        default: "Get latitude"
      src_path:
        default: "/data/vorticity/input/psl_6hrPlevPt_CMCC-CM2-VHR4_highresSST-future_r1i1p1f1_gn_201502010000-201502010600.nc"
      measure:
        default: "lat"
      imp_dim:
        default: "lat"
      container:
        default: "wind"
      nfrag:
        default: 1
      subset_dims:
        default: "lat"
      subset_filter:
        default: "0:70"
      subset_type:
        default: "coord"
    out: [experiment]
  Evaluate_latitude_factor:
    run: tasks/apply.cwl
    in:
      experiment: Get_latitude/experiment
      name:
        default: "Evaluate latitude factor"
      query:
        default: "oph_matheval('oph_double','oph_float',measure,'cos(pi*x/180)')"
    out: [experiment]

  Iterate_on_time:
    run: tasks/for.cwl
    in:
      experiment: Create_a_work_container/experiment
      name:
        default: "Iterate on time"
      parallel:
        default: "yes"
      key:
        default: "source"
      input:
        default: "[/data/vorticity/input/psl_*.nc]"
    out: [experiment]

  Import_PSL:
    run: tasks/importnc2.cwl
    in:
      experiment: Iterate_on_time/experiment
      name:
        default: "Import PSL"
      src_path:
        default: "@source"
      measure:
        default: "psl"
      imp_dim:
        default: "lat"
      container:
        default: "wind"
      subset_dims:
        default: "lat|lon"
      subset_filter:
        default: "0:70|100:320"
      subset_type:
        default: "coord"
      nfrag: nthreads
      nthreads: nthreads
    out: [experiment]
  Export_PSL:
    run: tasks/exportnc2.cwl
    in:
      experiment: Import_PSL/experiment
      name:
        default: "Export PSL"
      output:
        default: "/data/vorticity/output/@{source_file}"
    out: [experiment]
  Regrid_PSL:
    run: tasks/script.cwl
    in:
      experiment: Export_PSL/experiment
      name:
        default: "Regrid PSL"
      command:
        default: "/path/to/regrid.sh"
      args:
        default: "/data/vorticity/output/@{source_file} 0:70 100:320 r880x280"
    out: [experiment]

  Import_U:
    run: tasks/importnc2.cwl
    in:
      experiment: Iterate_on_time/experiment
      name:
        default: "Import U"
      src_path:
        default: "@{source_path}/ua_@{source_file+4}"
      measure:
        default: "ua"
      imp_dim:
        default: "lat"
      container:
        default: "wind"
      subset_dims:
        default: "plev|lat|lon"
      subset_filter:
        default: "85000|0:70|100:320"
      subset_type:
        default: "coord"
      nfrag: nthreads
      nthreads: nthreads
    out: [experiment]
  Evaluate_du_dlat:
    run: tasks/apply.cwl
    in:
      experiment: Import_U/experiment
      name:
        default: "Evaluate du/dlat"
      query:
        default: "oph_matheval(oph_gsl_spline(measure,dimension,dimension,1),'180*x/(6372507*pi)')"
      measure_type:
        default: "auto"
    out: [experiment]
  Rollup_U:
    run: tasks/rollup.cwl
    in:
      experiment: Evaluate_du_dlat/experiment
      name:
        default: "Rollup U"
    out: [experiment]
  Permute_U:
    run: tasks/permute.cwl
    in:
      experiment: Rollup_U/experiment
      name:
        default: "Permute U"
      dim_pos:
        default: "2,1"
    out: [experiment]

  Import_V:
    run: tasks/importnc2.cwl
    in:
      experiment: Iterate_on_time/experiment
      name:
        default: "Import V"
      src_path:
        default: "@{source_path}/va_@{source_file+4}"
      measure:
        default: "va"
      imp_dim:
        default: "lon"
      container:
        default: "wind"
      subset_dims:
        default: "plev|lat|lon"
      subset_filter:
        default: "85000|0:70|100:320"
      subset_type:
        default: "coord"
      nfrag: nthreads
      nthreads: nthreads
    out: [experiment]
  Evaluate_dv_dlon:
    run: tasks/apply.cwl
    in:
      experiment: Import_V/experiment
      name:
        default: "Evaluate dv/dlon"
      query:
        default: "oph_matheval(oph_gsl_spline(measure,dimension,dimension,1),'180*x/(6372507*pi)')"
      measure_type:
        default: "auto"
    out: [experiment]
  Rollup_V:
    run: tasks/rollup.cwl
    in:
      experiment: Evaluate_dv_dlon/experiment
      name:
        default: "Rollup V"
    out: [experiment]
  Put_latitude_factor:
    run: tasks/intercube.cwl
    in:
      experiment1: Rollup_V/experiment
      experiment2: Evaluate_latitude_factor/experiment
      name:
        default: "Put latitude factor"
      operation:
        default: "div"
      cube2_is_array:
        default: "yes"
      extension_type:
        default: "interlace"
    out: [experiment]

  Evaluate_vorticity:
    run: tasks/intercube.cwl
    in:
      experiment1: Permute_U/experiment
      experiment2: Put_latitude_factor/experiment
      name:
        default: "Evaluate vorticity"
      measure:
        default: "rv850"
    out: [experiment]

  Delete_metadata:
    run: tasks/metadata.cwl
    in:
      experiment: Evaluate_vorticity/experiment
      name:
        default: "Delete metadata"
      mode:
        default: "delete"
      variable:
        default: "rv850"
      metadata_key:
        default: "comment"
    out: [experiment]
  Update_metadata:
    run: tasks/metadata.cwl
    in:
      experiment: Delete_metadata/experiment
      name:
        default: "Update metadata"
      mode:
        default: "update"
      variable:
        default: "rv850"
      metadata_key:
        default: "standard_name|long_name|units"
      metadata_value:
        default: "atmosphere_relative_vorticity|Vorticity (relative)|s**-1"
      force:
        default: "yes"
    out: [experiment]
  Export_VO:
    run: tasks/exportnc2.cwl
    in:
      experiment: Update_metadata/experiment
      name:
        default: "Export VO"
      output:
        default: "/data/vorticity/output/vo_@{source_file+4}"
    out: [experiment]
  Regrid_VO:
    run: tasks/script.cwl
    in:
      experiment: Export_VO/experiment
      name:
        default: "Regrid VO"
      command:
        default: "/path/to/regrid.sh"
      args:
        default: "/data/vorticity/output/vo_@{source_file+4} 0:70 100:320 r880x280"
    out: [experiment]

  End_iteration:
    run: tasks/endfor.cwl
    in:
      experiment: [Regrid_VO/experiment, Regrid_PSL/experiment]
      name:
        default: "End iteration"
    out: [experiment]

