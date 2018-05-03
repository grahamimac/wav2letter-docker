#!/bin/bash
# Install wav2letter CPU - modified from https://github.com/facebookresearch/wav2letter

# Install dependencies
apt-get update -y
apt-get install git wget curl cmake build-essential apt-utils unzip apt-transport-https -y
apt-get install libboost-dev libboost-system-dev libboost-thread-dev libboost-test-dev libboost-all-dev zlib1g-dev bzip2 libbz2-dev liblzma-dev -y
apt-get install libfftw3-dev libfftw3-doc libsndfile-dev -y

# Install MKL - modified from https://github.com/eddelbuettel/mkl4deb/blob/master/script.sh
cd /tmp
wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
sh -c 'echo deb https://apt.repos.intel.com/mkl all main > /etc/apt/sources.list.d/intel-mkl.list'
apt-get update -y
apt-get install intel-mkl-64bit-2018.2-046 -y
update-alternatives --install /usr/lib/x86_64-linux-gnu/libblas.so     libblas.so-x86_64-linux-gnu      /opt/intel/mkl/lib/intel64/libmkl_rt.so 50
update-alternatives --install /usr/lib/x86_64-linux-gnu/libblas.so.3   libblas.so.3-x86_64-linux-gnu    /opt/intel/mkl/lib/intel64/libmkl_rt.so 50
update-alternatives --install /usr/lib/x86_64-linux-gnu/liblapack.so   liblapack.so-x86_64-linux-gnu    /opt/intel/mkl/lib/intel64/libmkl_rt.so 50
update-alternatives --install /usr/lib/x86_64-linux-gnu/liblapack.so.3 liblapack.so.3-x86_64-linux-gnu  /opt/intel/mkl/lib/intel64/libmkl_rt.so 50
echo "/opt/intel/lib/intel64"     >  /etc/ld.so.conf.d/mkl.conf
echo "/opt/intel/mkl/lib/intel64" >> /etc/ld.so.conf.d/mkl.conf
ldconfig
echo "MKL_THREADING_LAYER=GNU" >> /etc/environment

# Update bashrc file to include mkl
echo 'export PATH=$HOME/usr/bin:$PATH' >> ~/.bashrc
echo 'INTEL_DIR=/opt/intel/lib/intel64' >> ~/.bashrc
echo 'MKL_DIR=/opt/intel/mkl/lib/intel64' >> ~/.bashrc
echo 'MKL_INC_DIR=/opt/intel/mkl/include' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$INTEL_DIR:$MKL_DIR' >> ~/.bashrc
echo 'export CMAKE_LIBRARY_PATH=$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export CMAKE_INCLUDE_PATH=$CMAKE_INCLUDE_PATH:$MKL_INC_DIR' >> ~/.bashrc
source ~/.bashrc

# LuaJIT and LuaRocks
git clone https://github.com/torch/luajit-rocks.git
cd luajit-rocks
mkdir build; cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/usr -DWITH_LUAJIT21=OFF
make -j 4
make install
cd ../..

# KenLM
wget https://kheafield.com/code/kenlm.tar.gz
tar xfvz kenlm.tar.gz
rm kenlm.tar.gz
cd kenlm
mkdir build && cd build
export EIGEN3_ROOT=$HOME/eigen-eigen-07105f7124f9
(cd $HOME; wget -O - https://bitbucket.org/eigen/eigen/get/3.2.8.tar.bz2 |tar xj)
cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/usr -DCMAKE_POSITION_INDEPENDENT_CODE=ON
make -j 4
make install
cp -a lib/* ~/usr/lib
cd ../..

# OpenMPI
wget https://www.open-mpi.org/software/ompi/v3.0/downloads/openmpi-3.0.1.tar.bz2
tar xfj openmpi-3.0.1.tar.bz2
rm openmpi-3.0.1.tar.bz2 
cd openmpi-3.0.1; mkdir build; cd build
../configure --prefix=$HOME/usr --enable-mpi-cxx --enable-shared --with-slurm --enable-mpi-ext=affinity
make -j 20 all
make install
cd ../..

# TorchMPI
MPI_CXX_COMPILER=$HOME/usr/bin/mpicxx ~/usr/bin/luarocks install torchmpi

# wav2letter packages
git clone https://github.com/facebookresearch/wav2letter.git
cd wav2letter
cd gtn && ~/usr/bin/luarocks make rocks/gtn-scm-1.rockspec && cd ..
cd speech && ~/usr/bin/luarocks make rocks/speech-scm-1.rockspec && cd ..
cd torchnet-optim && ~/usr/bin/luarocks make rocks/torchnet-optim-scm-1.rockspec && cd ..
cd wav2letter && ~/usr/bin/luarocks make rocks/wav2letter-scm-1.rockspec && cd ..
cd beamer && KENLM_INC=/kenlm ~/usr/bin/luarocks make rocks/beamer-scm-1.rockspec && cd ..
cd ..

# Ready
# Example: ~/usr/bin/luajit /wav2letter/test.lua /librispeech-glu-highdropout-cpu.bin -progress -show -test dev-clean -save -datadir /librispeech-proc/ -dictdir /librispeech-proc/ -gfsai
