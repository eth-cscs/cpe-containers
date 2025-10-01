ARG SLE_VER=15.5
FROM jfrog.svc.cscs.ch/dockerhub/opensuse/leap:$SLE_VER

ARG CUDA_RPM_REPO=https://developer.download.nvidia.com/compute/cuda/repos/sles15/sbsa
ARG CUDA_RPM_REPO_KEY=https://developer.download.nvidia.com/compute/cuda/repos/sles15/sbsa/D42D0685.pub
ARG RPM_REPO
ARG CPE_VER=24.07
ARG SLE_VER

# install system software
ARG PKGS_SYSTEM
RUN for i in {1..5} ; do zypper install --recommends -y $PKGS_SYSTEM && break ; done

# install cuda toolkit
ARG PKGS_CUDA
RUN if [[ -n "$PKGS_CUDA" ]] ; then \
      rpm --import "${CUDA_RPM_REPO_KEY}" \
      && echo "Using cuda rpm repo=${CUDA_RPM_REPO}" \
      && zypper addrepo -f "${CUDA_RPM_REPO}" cuda \
      && zypper refresh \
      && for i in {1..5} ; do zypper install --recommends -y $PKGS_CUDA && break ; done  \
      && echo "/usr/local/cuda/lib64/stubs" > /etc/ld.so.conf.d/cuda-stubs.conf \
      && ldconfig \
    ; fi

#  && zypper addrepo -f $RPM_REPO/24.07/base/sle/$SLE_VER/aarch64 cpe-2407 \
# install cray programming environment
# CPE-24.* has separate repositories for aarch64 and x86_64, while later versions have
# one `repodata` directory for both architectures, and the package manager picks up the
# correct packages for the architecture
ARG PKGS_CRAY
RUN rpm --import $RPM_REPO/HPE-RPM-PROD-KEY-FIPS.public \
  && if [[ "$SLE_VER" == "24."* ]] ; then \
        zypper addrepo -f $RPM_REPO/$CPE_VER/base/sle/$SLE_VER/$(uname -m) cpe ; \
     else \
        zypper addrepo -f $RPM_REPO/$CPE_VER/base/sle/$SLE_VER cpe ; \
     fi \
  && zypper refresh \
  && for i in {1..5} ; do zypper install --recommends -y $PKGS_CRAY && break ; done \
  && /opt/cray/pe/cpe/$CPE_VER/set_default_release_$CPE_VER.sh \
  && zypper rr cpe cpe-2407


# add xpmem pkgconfig - during runtime CE injects xpmem
ADD cray-xpmem.pc /usr/lib64/pkgconfig/cray-xpmem.pc
ADD cray-xpmem.modulefile /opt/cray/modulefiles/xpmem/2.9.6

# add cuda module
ADD cuda.lua /opt/cscs/modulefiles/cuda/unversioned.lua
RUN mv /opt/cscs/modulefiles/cuda/unversioned.lua /opt/cscs/modulefiles/cuda/$(/usr/local/cuda/bin/nvcc --version | grep release | sed -e 's/.*release \([0-9.]\+\).*/\1/').lua

# only libxpmem.so.0 is injected - ensure that we link the unversioned one to the injected one
RUN ln -s /usr/lib64/libxpmem.so.0 /usr/lib64/libxpmem.so

# load some modules by default
ARG DEFAULT_MODULES
RUN if [[ -n "$DEFAULT_MODULES" ]] ; then echo "module load $DEFAULT_MODULES" > /etc/profile.d/zz_default-modules.sh ; fi

# use programming environment by default
ENV MODULEPATH=/opt/cray/pe/lmod/modulefiles/craype-targets/default:/opt/cray/pe/lmod/modulefiles/core:/opt/cray/modulefiles:/opt/cscs/modulefiles
ENV CXX=CC
ENV CC=cc
ENV FC=ftn
ENV F77=ftn

# ensure nvidia driver is mounted by CE
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# enable GPU-enabled MPI by default
ENV MPICH_GPU_SUPPORT_ENABLED=1

# Default variableCMake variables for good defaults
ENV NVCC_CCBIN=CC
ENV NVCC_PREPEND_FLAGS="--generate-code=arch=compute_90,code=[compute_90,sm_90]"

# Fix an issue where stubs redundant configuration messed up the ldconfig of containers
RUN rm /etc/ld.so.conf.d/cuda-stubs.conf

CMD ["/bin/bash", "-l"]
