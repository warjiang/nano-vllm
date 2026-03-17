# Nano-vLLM Docker Image
# A lightweight vLLM implementation built from scratch
# Supports: linux/amd64, linux/arm64

# Use NVIDIA CUDA base image with Python 3.10
# Note: CUDA images support both amd64 and arm64 architectures
FROM nvidia/cuda:12.1.0-devel-ubuntu22.04

# Build arguments for metadata
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=0.2.0

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
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# Detect architecture and set environment variables
RUN dpkgArch="$(dpkg --print-architecture)" && \
    echo "Building for architecture: ${dpkgArch}" && \
    case "${dpkgArch}" in \
        amd64) echo "x86_64 architecture detected" ;; \
        arm64) echo "ARM64 architecture detected" ;; \
        *) echo "Unsupported architecture: ${dpkgArch}" && exit 1 ;; \
    esac

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

# Upgrade pip
RUN python -m pip install --upgrade pip setuptools wheel

# Install PyTorch with CUDA support
# PyTorch automatically selects the correct wheel for the architecture
RUN pip install --no-cache-dir \
    packaging \
    ninja \
    torch>=2.4.0 \
    triton>=3.0.0

# Set working directory
WORKDIR /workspace

# Copy project files
COPY pyproject.toml README.md LICENSE ./
COPY nanovllm/ ./nanovllm/
COPY example.py bench.py ./

# Install the package
# Note: flash-attn compilation takes a while on both architectures
# For ARM64, flash-attn may take significantly longer to compile
RUN pip install --no-cache-dir -e .

# Install huggingface-cli for model download
RUN pip install --no-cache-dir huggingface-hub

# Create directory for model weights
RUN mkdir -p /workspace/models

# Set environment variable for HuggingFace cache
ENV HF_HOME=/workspace/.cache/huggingface
ENV HUGGINGFACE_HUB_CACHE=/workspace/.cache/huggingface/hub

# Expose port for potential API service
EXPOSE 8000

# Default command
CMD ["python", "example.py"]
