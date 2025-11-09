#!/bin/bash

set -e

RelWorkDir="`dirname \"$0\"`"
AbsWorkDir="`( cd \"$RelWorkDir\" && pwd )`"

sudo -i -u jovyan $AbsWorkDir/inference.py ${1} ${2} ${3}

exit 0

