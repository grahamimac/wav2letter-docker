#!/bin/bash
# Install wav2letter CPU - modified from https://github.com/facebookresearch/wav2letter
# On AWS Deep Learning AMI Ubuntu

# Install dependencies
apt-get update -y
apt-get install libfftw3-dev libfftw3-doc libsndfile-dev -y

# Need to find MKL libraries and change env so other programs can locate them...

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
../configure --prefix=$HOME/usr --enable-mpi-cxx --enable-shared --with-slurm --enable-mpi-ext=affinity,cuda #--with-cuda=/public/apps/cuda/9.0 - need to find where CUDA is on AMI
make -j 20 all
make install
cd ../..

# TorchMPI
MPI_CXX_COMPILER=$HOME/usr/bin/mpicxx ~/usr/bin/luarocks install torchmpi
~/usr/bin/luarocks install cudnn
~/usr/bin/luarocks install cunn 
