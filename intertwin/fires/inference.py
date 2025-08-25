#!/usr/bin/env python

target_dir = "/ML4Fires"

import os, sys
sys.path.append(target_dir)
os.chdir(target_dir)

# Arguments
output_name = sys.argv[1]
input_file = sys.argv[2]
output_file = sys.argv[3]

# Body
import numpy as np
import xarray as xr
import toml
import munch
from tqdm import tqdm
import torch
import datetime

import warnings
warnings.filterwarnings("ignore")

from Fires._utilities.utils_mlflow import load_model_from_mlflow
from batch_prediction import get_prediction_for_data

run_name = "model"
#_ = load_model_from_mlflow(run_name, provenance=True)

prediction = get_prediction_for_data(dataset_path=input_file,
                                     model_path=f"MLFLOW/{run_name}/last_model/data/model.pth",
                                     output_name=output_name)
prediction.to_netcdf(output_file)

