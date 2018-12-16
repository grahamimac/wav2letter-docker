# Modified from https://github.com/facebookresearch/wav2letter/issues/17
FROM nvidia/cuda

# Install dependencies.
RUN apt-get update -y && apt-get install -y cmake curl git-core libboost-all-dev libbz2-dev libfftw3-dev liblzma-dev libsndfile1-dev lua5.3 lua5.3-dev wget zlib1g-dev unzip

# Install luajit
RUN cd /usr/src; \
	git clone https://github.com/torch/luajit-rocks.git; \
	cd luajit-rocks; \
	mkdir build; \
	cd build; \
	cmake .. -DWITH_LUAJIT21=OFF; \
	make -j 4; \
	make install

# Install KenLM
RUN cd /usr/src; \
	git clone https://github.com/kpu/kenlm.git; \
	cd kenlm; \
	mkdir build; \
	cd build; \
	export EIGEN3_ROOT=$HOME/eigen-eigen-07105f7124f9; \
	(cd $HOME; wget -O - https://bitbucket.org/eigen/eigen/get/3.2.8.tar.bz2 |tar xj); \
	cmake .. -DCMAKE_POSITION_INDEPENDENT_CODE=ON; \
	make -j 4; \
	make install; \
	cp -a lib/* /usr/lib

# Update CMAKE to install torch packages (need to remove interactive element...)
RUN apt-get remove cmake -y;
	cd /; 
	wget https://github.com/Kitware/CMake/releases/download/v3.13.2/cmake-3.13.2-Linux-x86_64.sh; \
	sh cmake-3.13.2-Linux-x86_64.sh; \
	export CMAKE_ROOT=/cmake-3.13.2-Linux-x86_64/share/cmake-3.13; \
	ln -s /cmake-3.13.2-Linux-x86_64/bin/* /usr/bin

# Alternate CMAKE install without interactive to test
RUN wget http://www.cmake.org/files/v3.10/cmake-3.10.1.tar.gz 
	tar -xvzf cmake-3.10.1.tar.gz 
	cd cmake-3.10.1/ 
	./configure 
	make
	make install
	update-alternatives --install /usr/bin/cmake cmake /usr/local/bin/cmake 1 --force

# Install torch packages.
RUN luarocks install torch; \
RUN luarocks install cutorch
RUN luarocks install cudnn
RUN luarocks install cunn
RUN git clone https://github.com/soumith/cudnn.torch.git -b R7
WORKDIR cudnn.torch
RUN luarocks make cudnn-scm-1.rockspec
WORKDIR /usr/src

# Fetch the wav2letter source.
WORKDIR /var/lib
RUN git clone https://github.com/facebookresearch/wav2letter.git

# Install additional dependencies
RUN luarocks install threads
RUN luarocks install optim
RUN luarocks install luafilesystem
RUN luarocks install md5
RUN luarocks install tds

RUN luarocks install torchnet
RUN luarocks install sys
RUN luarocks install vector

RUN luarocks install torchnet-sequential
RUN luarocks install xlua
RUN luarocks install sndfile

# Build wav2letter packages.
WORKDIR wav2letter
RUN cd gtn && luarocks make rocks/gtn-scm-1.rockspec && cd ..
RUN cd speech && luarocks make rocks/speech-scm-1.rockspec && cd ..
RUN cd torchnet-optim && luarocks make rocks/torchnet-optim-scm-1.rockspec && cd ..
RUN cd wav2letter && luarocks make rocks/wav2letter-scm-1.rockspec && cd ..
RUN cd beamer && KENLM_INC=/usr/src/kenlm luarocks make rocks/beamer-scm-1.rockspec && cd ..