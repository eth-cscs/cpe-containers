#!/bin/bash

set -e

SCRIPT_DIR=$(dirname $(realpath $0))

source 24.07/aarch64/arg_common.txt

for type in gnu cray ; do
    source 24.07/aarch64/${type}/arg.txt
    echo -e "Building now with args\nPKGS_SYSTEM=$PKGS_SYSTEM\nPKGS_CUDA=$PKGS_CUDA\nPKGS_CRAY=$PKGS_CRAY\nDEFAULT_MODULES=$DEFAULT_MODULES"
    podman build \
        -f Dockerfile \
        --format docker \
        --build-arg PKGS_SYSTEM \
        --build-arg PKGS_CUDA \
        --build-arg PKGS_CRAY \
        --build-arg DEFAULT_MODULES \
        --build-arg RPM_REPO=https://jfrog.svc.cscs.ch/artifactory/proxy-hpe-rpm \
        -t cpe-${type}:latest \
        "${SCRIPT_DIR}"
done
