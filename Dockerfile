# Nano-vLLM Docker Image
# A lightweight vLLM implementation built from scratch
# Supports: linux/amd64

# Use NVIDIA CUDA base image with Python 3.10
FROM nvidia/cuda:12.1.0-devel-ubuntu22.04

# Build arguments for metadata
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=0.2.0
ARG MAX_JOBS=4
ARG TORCH_VERSION=2.4.0
ARG TORCH_CUDA=cu121
ARG FLASH_ATTN_VERSION=2.8.3
ARG DOWNLOAD_MODEL=1

# Labels for the image
LABEL org.opencontainers.image.title="Nano-vLLM" \
      org.opencontainers.image.description="A lightweight vLLM implementation built from scratch" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.source="https://github.com/warjiang/nano-vllm" \
      org.opencontainers.image.licenses="MIT"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PIP_ROOT_USER_ACTION=ignore
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
ENV MAX_JOBS=${MAX_JOBS}

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-dev \
    python3-pip \
    git \
    wget \
    curl \
    vim \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Upgrade pip and install build tools
RUN python -m pip install --upgrade pip setuptools wheel packaging ninja

# Install PyTorch with CUDA support
RUN pip install --no-cache-dir --index-url https://download.pytorch.org/whl/${TORCH_CUDA} "torch==${TORCH_VERSION}+${TORCH_CUDA}" && \
    pip install --no-cache-dir "triton>=3.0.0"

RUN pip install --no-cache-dir --prefer-binary "flash-attn==${FLASH_ATTN_VERSION}" --no-build-isolation

# Install other dependencies
RUN pip install --no-cache-dir transformers>=4.51.0 xxhash

# Set working directory
WORKDIR /workspace

# Copy project files
COPY pyproject.toml README.md LICENSE ./
COPY nanovllm/ ./nanovllm/
COPY example.py bench.py ./

# Install the package without dependencies (all already installed)
RUN pip install --no-cache-dir -e . --no-deps

# Install huggingface-cli for model download
RUN python -m pip install --no-cache-dir huggingface-hub

# Set environment variable for HuggingFace cache
ENV HF_HOME=/workspace/.cache/huggingface
ENV HUGGINGFACE_HUB_CACHE=/workspace/.cache/huggingface/hub

# Download default model (Qwen/Qwen3-0.6B) during build
# This makes the image ready to use immediately
RUN mkdir -p /workspace/models/Qwen3-0.6B && \
    if [ "${DOWNLOAD_MODEL}" = "1" ]; then python -m huggingface_hub.cli download Qwen/Qwen3-0.6B --local-dir /workspace/models/Qwen3-0.6B --local-dir-use-symlinks False; fi

# Expose port for potential API service
EXPOSE 8000

# Set default model path environment variable
ENV MODEL_PATH=/workspace/models/Qwen3-0.6B

# Default command
CMD ["python", "example.py"]
