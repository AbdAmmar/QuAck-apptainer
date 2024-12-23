#!/bin/bash -e

cd /opt
source env.rc

if [ $ARCH = x86_64 ] ; then

  APT_NOT_REQUIRED="wget pgpgpg"
  apt install -y $APT_NOT_REQUIRED

  wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
  | gpg --dearmor \
  | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null

  echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
  | tee /etc/apt/sources.list.d/oneAPI.list

  apt update

  apt install -y intel-oneapi-compiler-fortran \
                 intel-oneapi-compiler-fortran-runtime \
                 intel-oneapi-compiler-dpcpp-cpp \
                 intel-oneapi-compiler-dpcpp-cpp-runtime \
                 intel-oneapi-openmp \
                 intel-oneapi-mkl-classic

  ln -s /opt/intel/oneapi/compiler/latest/bin/ifort.cfg /opt/ifort.cfg
  ln -s /opt/intel/oneapi/compiler/latest/bin/icx.cfg /opt/icx.cfg
  ln -s /opt/intel/oneapi/compiler/latest/bin/ifx /opt/intel/oneapi/compiler/latest/bin/ifort

  echo "-diag-disable=10448" > /opt/ifort.cfg
  echo "-march=core-avx2" >> /opt/ifort.cfg
  echo "-march=core-avx2" >> /opt/icx.cfg

  ## Test
  #cd
  #source /opt/intel/oneapi/setvars.sh &>/dev/null || :
  #ifort --version || exit 1
  #icx --version || exit 1
  #mpirun hostname || exit 1

  # Clean up
  apt remove -y $APT_NOT_REQUIRED

elif [ $ARCH = aarch64 ] ; then

  update-alternatives --remove-all gcc || :
  update-alternatives --remove-all g++ || :
  update-alternatives --remove-all gfortran || :

  apt install -y build-essential gcc-12 g++-12 gfortran-12 libopenblas0 openmpi-bin libopenblas-dev libopenmpi-dev

  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11  10
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12  20

  update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11  10
  update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12  20

  update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-11  10
  update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-12  20

  update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 30
  update-alternatives --set cc /usr/bin/gcc

  update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 30
  update-alternatives --set c++ /usr/bin/g++

else 

  exit 1

fi

