#!/bin/bash

set -e

SCRIPT_DIR=$(dirname $(realpath $0))

if [[ -z $1 ]] ; then
    echo "First argument must be a configuration to build e.g. 24.07/gh200/gnu.yaml"
    exit 1
fi

python3 generate_dockerfile.py "$1"

podman build \
  -f Dockerfile.rendered \
  --format docker \
  -t cpe-$(basename $1 .yaml):latest \
  "${SCRIPT_DIR}"
