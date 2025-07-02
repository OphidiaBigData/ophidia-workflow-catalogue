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

outputs:
  outputexperiment:
    type: File
    outputSource: End_iteration_on_scenarios/experiment

steps:
  Create_a_work_container:
    run: tasks/createcontainer.cwl
    in:
      experiment: inputexperiment
      name:
        default: "Create a work container"
      container:
        default: "fires"
      dim:
        default: "time|lat|lon"
      hierarchy:
        default: "oph_time|oph_base|oph_base"
      on_error:
        default: "skip"
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
        default: "CMCC-ESM2"
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
        default: "pr"
    out: [experiment]
  Import_variable:
    run: tasks/importncs.cwl
    in:
      experiment: Iterate_on_variables/experiment
      name:
        default: "Import variable"
      imp_dim:
        default: "time"
      measure:
        default: "@variable"
      src_path:
        default: "/data/fires/@{model}/@{scenario}/@{variable}/@{variable}_day_@{model}_@{scenario}_r1i1p1f1_gn_*.nc"
      container:
        default: "fires"
      subset_dims:
        default: "time"
      subset_filter:
        default: "2090-01-01_2090-01-15"
      subset_type:
        default: "coord"
      nfrag: nthreads
      nthreads: nthreads
    out: [experiment]
  Reduction_on_octets:
    run: tasks/reduce2.cwl
    in:
      experiment: Import_variable/experiment
      name:
        default: "Reduction on octets"
      operation:
        default: "median"
      concept_level:
        default: "o"
    out: [experiment]
  Export_variable:
    run: tasks/exportnc2.cwl
    in:
      experiment: Reduction_on_octets/experiment
      name:
        default: "Export variable"
      output:
        default: "/data/fires/output/@{variable}_day_@{model}_@{scenario}_r1i1p1f1_gn_2090-01-01_2090-01-15.nc"
    out: [experiment]
  Regrid_variable:
    run: tasks/script.cwl
    in:
      experiment: Export_variable/experiment
      name:
        default: "Regrid variable"
      script:
        default: "/path/to/regrid.sh"
      args:
        default: "/data/fires/output/@{variable}_day_@{model}_@{scenario}_r1i1p1f1_gn_2090-01-01_2090-01-15.nc -90:90 0:360 r360x180"
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
  Python_script:
    run: tasks/script.cwl
    in:
      experiment: End_iteration_on_variables/experiment
      name:
        default: "Python script"
      script:
        default: "/path/to/fires.sh"
      args:
        default: "/data/fires/output/ @model @scenario tos"
    out: [experiment]
  Import_model:
    run: tasks/importnc2.cwl
    in:
      experiment: Python_script/experiment
      name:
        default: "Import model"
      imp_dim:
        default: "time"
      measure:
        default: "tos"
      src_path:
        default: "/data/fires/output/@{model}_@{scenario}.nc"
      container:
        default: "fires"
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
  End_iteration_on_models:
    run: tasks/endfor.cwl
    in:
      experiment:
        source: Reduction_on_years/experiment
        valueFrom: ${ return [ self ]; }
      name:
        default: "End iteration on models"
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
        default: "/data/fires/output/@{operation}_@{scenario}.nc"
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
