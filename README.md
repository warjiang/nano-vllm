<p align="center">
<img width="300" src="assets/logo.png">
</p>

<p align="center">
<a href="https://trendshift.io/repositories/15323" target="_blank"><img src="https://trendshift.io/api/badge/repositories/15323" alt="GeeeekExplorer%2Fnano-vllm | Trendshift" style="width: 250px; height: 55px;" width="250" height="55"/></a>
</p>

# Nano-vLLM

A lightweight vLLM implementation built from scratch.

## Key Features

* 🚀 **Fast offline inference** - Comparable inference speeds to vLLM
* 📖 **Readable codebase** - Clean implementation in ~ 1,200 lines of Python code
* ⚡ **Optimization Suite** - Prefix caching, Tensor Parallelism, Torch compilation, CUDA graph, etc.

## Installation

```bash
pip install git+https://github.com/warjiang/nano-vllm.git
```

## Model Download

To download the model weights manually, use the following command:
```bash
huggingface-cli download --resume-download Qwen/Qwen3-0.6B \
  --local-dir ~/huggingface/Qwen3-0.6B/ \
  --local-dir-use-symlinks False
```

## Quick Start

See `example.py` for usage. The API mirrors vLLM's interface with minor differences in the `LLM.generate` method:
```python
from nanovllm import LLM, SamplingParams
llm = LLM("/YOUR/MODEL/PATH", enforce_eager=True, tensor_parallel_size=1)
sampling_params = SamplingParams(temperature=0.6, max_tokens=256)
prompts = ["Hello, Nano-vLLM."]
outputs = llm.generate(prompts, sampling_params)
outputs[0]["text"]
```

## Benchmark

See `bench.py` for benchmark.

**Test Configuration:**
- Hardware: RTX 4070 Laptop (8GB)
- Model: Qwen3-0.6B
- Total Requests: 256 sequences
- Input Length: Randomly sampled between 100–1024 tokens
- Output Length: Randomly sampled between 100–1024 tokens

**Performance Results:**
| Inference Engine | Output Tokens | Time (s) | Throughput (tokens/s) |
|----------------|-------------|----------|-----------------------|
| vLLM           | 133,966     | 98.37    | 1361.84               |
| Nano-vLLM      | 133,966     | 93.41    | 1434.13               |

## Remote Docker Dev Workflow

Configure defaults in `.env` first (recommended), then use these scripts from local:

```bash
# 1) One-time sync local code -> remote mount path
./scripts/dev_sync_once.sh

# 2) Keep syncing while you edit locally
./scripts/dev_sync_watch.sh

# 3) From local, ssh to remote and run docker with volume mount + pip install -e .
./scripts/dev_run_remote_docker.sh
```

By default, the scripts use:
- Remote host: `<REMOTE_HOST>`
- Remote sync path: `/data00/dev/$USER/nano-vllm-sync`
- Container mount: `${REMOTE_SYNC_DIR} -> /workspace/nano-vllm`
- Models mount: `/data00/models -> /workspace/models:ro`
- Image: `<PRIVATE_IMAGE>`

You can override with environment variables:

```bash
REMOTE_HOST=<REMOTE_HOST> \
REMOTE_SYNC_DIR=/data00/dev/$USER/nano-vllm-sync \
MODEL_DIR=/data00/models \
IMAGE=<PRIVATE_IMAGE> \
./scripts/dev_run_remote_docker.sh
```

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=warjiang/nano-vllm&type=Date)](https://www.star-history.com/#warjiang/nano-vllm&Date)
