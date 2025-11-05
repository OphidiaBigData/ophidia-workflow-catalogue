#!/bin/bash

set -e

target_dir=${1}
echo "Clear folder $target_dir"

rm -rf $target_dir/*.nc

exit 0
