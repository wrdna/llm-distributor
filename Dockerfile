# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    cmake \
    software-properties-common \
    gnupg \
    && apt-get clean

# Add NVIDIA repository for CUDA
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb && \
    apt-get update

# Install CUDA toolkit and cuDNN
RUN apt-get install -y \
    cuda-toolkit-12-2 \
    && apt-get clean

# Add CUDA to the environment paths
ENV PATH="/usr/local/cuda/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"

# Clone llama.cpp and build it
WORKDIR /opt/llama.cpp
RUN git clone https://github.com/ggerganov/llama.cpp.git . && \
    mkdir build && cd build && \
    cmake .. -DGGML_CUDA=ON -DGGML_RPC=ON -DCUDAToolkit_ROOT=/usr/local/cuda && \
    make -j$(nproc)

# Expose the RPC server port
EXPOSE 50052

# Default command to run the RPC server
CMD ["./build/bin/rpc-server", "-p", "50052"]

