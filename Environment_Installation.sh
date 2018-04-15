#!/bin/bash
# Install wav2letter CPU

# Install dependencies
apt-get update -y
apt-get install git wget curl cmake build-essential apt-utils unzip -y
apt-get install libboost-dev libboost-system-dev libboost-thread-dev libboost-test-dev libboost-all-dev zlib1g-dev bzip2 libbz2-dev liblzma-dev -y
apt-get install libfftw3-dev libfftw3-doc libsndfile-dev -y

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