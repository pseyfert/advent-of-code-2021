one.o: one.cu
	/opt/nvidia/hpc_sdk/Linux_x86_64/2022/compilers/bin/nvcc -ccbin=gcc-11 --gpu-code sm_75 --gpu-architecture compute_75 one.cu -o one.o -DCOLS=${COLS} -DROWS=${ROWS} -c -g -DPADDING=${PADDING}

one: one.o read.o
	g++-11 read.o one.o -o one -L /opt/nvidia/hpc_sdk/Linux_x86_64/2022/cuda/lib64 -lcuda -lcudart -g

run: one
	LD_LIBRARY_PATH=/opt/nvidia/hpc_sdk/Linux_x86_64/2022/cuda/lib64/ ./one ${FILE}

read.o: read.cpp
	g++-11 read.cpp -std=c++20 -Wall -DCOLS=${COLS} -DROWS=${ROWS} -c -g -DPADDING=${PADDING}

