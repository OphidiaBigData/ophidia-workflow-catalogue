#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: Fires

requirements:
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  inputexperiment:
    type: File?
  nthreads: int
  container: string
  time_range: string

outputs:
  outputexperiment:
    type: File
    outputSource: Destroy_the_work_container/experiment

steps:
  Init_frequency:
    run: tasks/set.cwl
    in:
      experiment: inputexperiment
      name:
        default: "Init frequency"
      key:
        default: "frequency"
      value:
        default: "Eday|day|day|day|day|fx"
    out: [experiment]
  Init_measure:
    run: tasks/set.cwl
    in:
      experiment: inputexperiment
      name:
        default: "Init measure"
      key:
        default: "measure"
      value:
        default: "lai|lst_day|rel_hum|t2m_min|pr|lsm"
    out: [experiment]
  Init_institutes:
    run: tasks/set.cwl
    in:
      experiment: inputexperiment
      name:
        default: "Init institutes"
      key:
        default: "institute"
      value:
        default: "CMCC|NCC"
    out: [experiment]
  Init_reduction_operations:
    run: tasks/set.cwl
    in:
      experiment: inputexperiment
      name:
        default: "Init reduction operations"
      key:
        default: "reduction_op"
      value:
        default: "median|median|median|median|sum|none"
    out: [experiment]
  Clear_output_folder:
    run: tasks/generic.cwl
    in:
      experiment: [ Init_frequency/experiment, Init_measure/experiment, Init_institutes/experiment, Init_reduction_operations/experiment ]
      name:
        default: "Clear output folder"
      command:
        default: "/home/jovyan/work/fires/clear.sh"
      input:
        default: "/home/jovyan/work/fires/output/"
      output:
        default: "null"
      on_error:
        default: "skip"
    out: [experiment]
  Create_a_work_container:
    run: tasks/createcontainer.cwl
    in:
      experiment: Clear_output_folder/experiment
      name:
        default: "Create a work container"
      container: container
      dim:
        default: "time|plev|lat|lon"
      hierarchy:
        default: "oph_time|oph_base|oph_base|oph_base"
      on_error:
        default: "skip"
    out: [experiment]

  Import_mask:
    run: tasks/importnc2.cwl
    in:
      experiment: Create_a_work_container/experiment
      name:
        default: "Import mask"
      imp_dim:
        default: "time"
      measure:
        default: "basis_regions"
      src_path:
        default: "/home/jovyan/work/fires/mask.nc"
      container: container
      nfrag: nthreads
      nthreads: nthreads
    out: [experiment]

  Iterate_on_scenarios:
    run: tasks/for.cwl
    in:
      experiment: Create_a_work_container/experiment
      name:
        default: "Iterate on scenarios"
      parallel:
        default: "yes"
      key:
        default: "scenario"
      values:
        default: "ssp126"
    out: [experiment]

  Iterate_on_models:
    run: tasks/for.cwl
    in:
      experiment: Iterate_on_scenarios/experiment
      name:
        default: "Iterate on models"
      parallel:
        default: "yes"
      key:
        default: "model"
      values:
        default: "CMCC-ESM2|NorESM2-MM"
    out: [experiment]

  Iterate_on_variables:
    run: tasks/for.cwl
    in:
      experiment: Iterate_on_models/experiment
      name:
        default: "Iterate on variables"
      parallel:
        default: "yes"
      key:
        default: "variable"
      values:
        default: "lai|tasmax|hur|tasmin|pr|sftlf"
    out: [experiment]

  Check_for_reduction_operation:
    run: tasks/if.cwl
    in:
      experiment: Iterate_on_variables/experiment
      name:
        default: "Check for reduction operation"
      condition:
        default: "&{variable}-6"
      forward:
        default: "yes"
    out: [experiment]

  Check_for_selection_operation:
    run: tasks/if.cwl
    in:
      experiment: Check_for_reduction_operation/experiment
      name:
        default: "Check for selection operation"
      condition:
        default: "&{variable}-3"
      forward:
        default: "yes"
    out: [experiment]

  Import_variable:
    run: tasks/importncs.cwl
    in:
      experiment: Check_for_selection_operation/experiment
      name:
        default: "Import variable"
      imp_dim:
        default: "time"
      measure:
        default: "@variable"
      src_path:
        default: "/home/jovyan/data/CMIP6/ScenarioMIP/@{institute_&{model}}/@{model}/@{scenario}/r1i1p1f1/@{frequency_&{variable}}/@{variable}/gn/*/@{variable}_@{frequency_&{variable}}_@{model}_@{scenario}_r1i1p1f1_gn*.nc"
      container: container
      subset_dims:
        default: "time"
      subset_filter: time_range
      subset_type:
        default: "coord"
      nfrag: nthreads
      nthreads: nthreads
    out: [experiment]

  Check_for_rescaling_operation:
    run: tasks/if.cwl
    in:
      experiment: Import_variable/experiment
      name:
        default: "Check for rescaling operation"
      condition:
        default: "step(&{variable}-5)*step(5-&{variable})"
      forward:
        default: "yes"
    out: [experiment]
  Rescale_pr:
    run: tasks/apply.cwl
    in:
      experiment: Check_for_rescaling_operation/experiment
      name:
        default: "Rescale pr"
      query:
        default: "oph_matheval(measure,'x*3600*24')"
      measure_type:
        default: "auto"
    out: [experiment]
  End_rescaling_selection:
    run: tasks/endif.cwl
    in:
      experiment:
        source: Rescale_pr/experiment
        valueFrom: ${ return [ self ]; }
      name:
        default: "End rescaling selection"
    out: [experiment]

  Else_selection:
    run: tasks/else.cwl
    in:
      experiment: Check_for_selection_operation/experiment
      name:
        default: "Else selection"
    out: [experiment]

  Import_hur:
    run: tasks/importncs.cwl
    in:
      experiment: Else_selection/experiment
      name:
        default: "Import hur"
      imp_dim:
        default: "time"
      measure:
        default: "@variable"
      src_path:
        default: "/home/jovyan/data/CMIP6/ScenarioMIP/@{institute_&{model}}/@{model}/@{scenario}/r1i1p1f1/@{frequency_&{variable}}/@{variable}/gn/*/@{variable}_@{frequency_&{variable}}_@{model}_@{scenario}_r1i1p1f1_gn*.nc"
      container: container
      subset_dims:
        default: "plev|time"
      time_range: time_range
      subset_filter: { valueFrom: '$("1|" + inputs.time_range)' }
      subset_type:
        default: "index|coord"
      nfrag: nthreads
      nthreads: nthreads
    out: [experiment]

  End_check_selection:
    run: tasks/endif.cwl
    in:
      experiment: [End_rescaling_selection/experiment, Import_hur/experiment]
      name:
        default: "End check selection"
    out: [experiment]

  Reduction_on_octets:
    run: tasks/reduce2.cwl
    in:
      experiment: End_check_selection/experiment
      name:
        default: "Reduction on octets"
      operation:
        default: "@{reduction_op_&{variable}}"
      concept_level:
        default: "o"
    out: [experiment]

  Else_reduction:
    run: tasks/else.cwl
    in:
      experiment: Check_for_reduction_operation/experiment
      name:
        default: "Else reduction"
    out: [experiment]

  Import_sftlf:
    run: tasks/importncs.cwl
    in:
      experiment: Else_reduction/experiment
      name:
        default: "Import sftlf"
      measure:
        default: "@variable"
      src_path:
        default: "/home/jovyan/data/CMIP6/ScenarioMIP/@{institute_&{model}}/@{model}/@{scenario}/r1i1p1f1/@{frequency_&{variable}}/@{variable}/gn/*/@{variable}_@{frequency_&{variable}}_@{model}_@{scenario}_r1i1p1f1_gn.nc"
      container: container
      nfrag:
        default: 1
    out: [experiment]

  Rescale_sftlf:
    run: tasks/apply.cwl
    in:
      experiment: Import_sftlf/experiment
      name:
        default: "Rescale sftlf"
      query:
        default: "oph_matheval(measure,'x/100')"
      measure_type:
        default: "auto"
    out: [experiment]

  End_check_reduction:
    run: tasks/endif.cwl
    in:
      experiment: [Reduction_on_octets/experiment, Rescale_sftlf/experiment]
      name:
        default: "End check reduction"
    out: [experiment]

  Rename_measure:
    run: tasks/apply.cwl
    in:
      experiment: End_check_reduction/experiment
      name:
        default: "Rename measure"
      measure:
        default: "@{measure_&{variable}}"
    out: [experiment]
  Export_variable:
    run: tasks/exportnc2.cwl
    in:
      experiment: Rename_measure/experiment
      name:
        default: "Export variable"
      output:
        default: "/home/jovyan/work/fires/output/@{variable}_@{frequency_&{variable}}_@{model}_@{scenario}_r1i1p1f1_gn.nc"
    out: [experiment]
  Regrid_variable:
    run: tasks/generic.cwl
    in:
      experiment:
        source: Export_variable/experiment
        valueFrom: ${ return [ self ]; }
      name:
        default: "Regrid variable"
      command:
        default: "/home/jovyan/work/fires/regrid.sh"
      args:
        default: "-90:90 0:360 interp_like @{measure_&{variable}}"
      input:
        default: "/home/jovyan/work/fires/output/@{variable}_@{frequency_&{variable}}_@{model}_@{scenario}_r1i1p1f1_gn.nc"
      output:
        default: "/home/jovyan/work/fires/output/regridded_@{model}_@{scenario}.nc"
    out: [experiment]

  End_iteration_on_variables:
    run: tasks/endfor.cwl
    in:
      experiment:
        source: Regrid_variable/experiment
        valueFrom: ${ return [ self ]; }
      name:
        default: "End iteration on variables"
    out: [experiment]

  Move_latlon:
    run: tasks/generic.cwl
    in:
      experiment:
        source: End_iteration_on_variables/experiment
        valueFrom: ${ return [ self ]; }
      name:
        default: "Move latlon"
      command:
        default: "/home/jovyan/work/fires/move_latlon.sh"
      input:
        default: "/home/jovyan/work/fires/output/regridded_@{model}_@{scenario}.nc"
      output:
        default: "/home/jovyan/work/fires/output/moved_@{model}_@{scenario}.nc"
    out: [experiment]
  Infer_data:
    run: tasks/generic.cwl
    in:
      experiment:
        source: Move_latlon/experiment
        valueFrom: ${ return [ self ]; }
      name:
        default: "Infer data"
      command:
        default: "/home/jovyan/work/fires/inference.py"
      input:
        default: "/home/jovyan/work/fires/output/moved_@{model}_@{scenario}.nc"
      output:
        default: "/home/jovyan/work/fires/output/fires_@{model}_@{scenario}.nc"
      args:
        default: "global_burned_areas"
    out: [experiment]
  Import_model:
    run: tasks/importnc2.cwl
    in:
      experiment: Infer_data/experiment
      name:
        default: "Import model"
      imp_dim:
        default: "time"
      measure:
        default: "global_burned_areas"
      src_path:
        default: "/home/jovyan/work/fires/output/fires_@{model}_@{scenario}.nc"
      container: container
      imp_concept_level:
        default: "o"
      nfrag: nthreads
      nthreads: nthreads
    out: [experiment]
  Reduction_on_years:
    run: tasks/reduce2.cwl
    in:
      experiment: Import_model/experiment
      name:
        default: "Reduction on years"
      operation:
        default: "avg"
      concept_level:
        default: "y"
    out: [experiment]
  Apply_the_mask:
    run: tasks/intercube.cwl
    in:
      experiment1: Reduction_on_years/experiment
      experiment2: Import_mask/experiment
      name:
        default: "Apply the mask"
      operation:
        default: "mul"
      extension_type:
        default: "append"
    out: [experiment]
  Export_model:
    run: tasks/exportnc2.cwl
    in:
      experiment: Apply_the_mask/experiment
      name:
        default: "Export model"
      output:
        default: "/home/jovyan/work/fires/output/inferenced_@{model}_@{scenario}.nc"
    out: [experiment]

  End_iteration_on_models:
    run: tasks/endfor.cwl
    in:
      experiment: [Apply_the_mask/experiment, Export_model/experiment]
      name:
        default: "End iteration on models"
      dependencies:
        default: "cube,"
    out: [experiment]

  Merge_models:
    run: tasks/mergecubes2.cwl
    in:
      experiment: End_iteration_on_models/experiment
      name:
        default: "Merge models"
      dim:
        default: "ensemble"
    out: [experiment]

  Iterate_on_ensemble_operations:
    run: tasks/for.cwl
    in:
      experiment: Merge_models/experiment
      name:
        default: "Iterate on ensemble operations"
      parallel:
        default: "yes"
      key:
        default: "operation"
      values:
        default: "avg|min|max|var|std"
    out: [experiment]
  Ensemble_operation:
    run: tasks/reduce2.cwl
    in:
      experiment: Iterate_on_ensemble_operations/experiment
      name:
        default: "Ensemble operation"
      operation:
        default: "@{operation}"
      dim:
        default: "ensemble"
    out: [experiment]
  Export_scenario:
    run: tasks/exportnc2.cwl
    in:
      experiment: Ensemble_operation/experiment
      name:
        default: "Export scenario"
      output:
        default: "/home/jovyan/work/fires/output/@{operation}_@{scenario}.nc"
    out: [experiment]
  End_iteration_on_ensemble_operations:
    run: tasks/endfor.cwl
    in:
      experiment:
        source: Export_scenario/experiment
        valueFrom: ${ return [ self ]; }
      name:
        default: "End iteration on ensemble operations"
    out: [experiment]

  End_iteration_on_scenarios:
    run: tasks/endfor.cwl
    in:
      experiment:
        source: End_iteration_on_ensemble_operations/experiment
        valueFrom: ${ return [ self ]; }
      name:
        default: "End iteration on scenarios"
    out: [experiment]

  Destroy_the_work_container:
    run: tasks/deletecontainer.cwl
    in:
      experiment: End_iteration_on_scenarios/experiment
      name:
        default: "Destroy the work container"
      container: container
      force:
        default: "yes"
      on_error:
        default: "skip"
    out: [experiment]

