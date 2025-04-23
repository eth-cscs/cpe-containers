#!/bin/bash

set -e

SCRIPT_DIR=$(dirname $(realpath $0))

CPE_VER="25.03"
SLE_VER="15.5"

source $CPE_VER/aarch64/arg_common.txt

for type in gnu cray ; do
    source $CPE_VER/aarch64/${type}/arg.txt
    echo -e "Building now with args\nPKGS_SYSTEM=$PKGS_SYSTEM\nPKGS_CUDA=$PKGS_CUDA\nPKGS_CRAY=$PKGS_CRAY\nDEFAULT_MODULES=$DEFAULT_MODULES"
    ( set -x
      podman build \
        -f Dockerfile \
        --format docker \
        --build-arg PKGS_SYSTEM \
        --build-arg PKGS_CUDA \
        --build-arg PKGS_CRAY \
        --build-arg CPE_VER="$CPE_VER" \
        --build-arg SLE_VER="$SLE_VER" \
        --build-arg DEFAULT_MODULES \
        --build-arg RPM_REPO=https://jfrog.svc.cscs.ch/artifactory/proxy-hpe-rpm \
        -t cpe-${type}:latest \
        "${SCRIPT_DIR}"
    )
done
