# GitHub Actions Workflow

## Docker Build and Push

This workflow automatically builds and pushes the Docker image to GitHub Container Registry (GHCR).

### Supported Platforms

- **linux/amd64** - x86_64 architecture (Intel/AMD CPUs)

### Triggers

The workflow runs on:
- **Push to `main` branch**: Builds and pushes with `latest` tag
- **Tag push (v*)**: Builds and pushes with semantic version tags (e.g., `v1.0.0` → `1.0.0`, `1.0`, `1`)
- **Pull requests**: Builds only (no push) to verify the Dockerfile
- **Manual trigger**: Via `workflow_dispatch` with optional custom tag

### Image Tags

Images are tagged with:
- `latest` - Latest stable build from main branch
- `main` - Latest build from main branch
- `pr-{number}` - Pull request builds
- `{version}` - Semantic version (e.g., `0.2.0`)
- `{major}.{minor}` - Short version (e.g., `0.2`)
- `{major}` - Major version only (e.g., `0`)
- `{sha}` - Git commit short SHA

### Usage

#### Pull from GHCR

```bash
# Login to GHCR (optional for public repos)
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Pull the latest image
docker pull ghcr.io/warjiang/nano-vllm:latest

# Pull a specific version
docker pull ghcr.io/warjiang/nano-vllm:v0.2.0
```

#### Run the container

```bash
docker run --rm --gpus all \
  -v ~/huggingface:/workspace/models:ro \
  ghcr.io/warjiang/nano-vllm:latest
```

### Required Permissions

The workflow requires these permissions:
- `packages: write` - To push images to GHCR
- `attestations: write` - To generate build attestations
- `id-token: write` - For OIDC token authentication

These are already configured in the workflow file.

### Secrets

No additional secrets are required. The workflow uses the built-in `GITHUB_TOKEN` which is automatically provided by GitHub Actions.

### Build Cache

The workflow uses GitHub Actions cache (`type=gha`) to speed up subsequent builds by caching Docker layers.

### Build Time Considerations

- **AMD64**: ~15-25 minutes (including flash-attn compilation and model download)

### Pre-installed Model

The Docker image includes the **Qwen/Qwen3-0.6B** model by default, so you can run inference immediately without downloading models separately.

Model location in container: `/workspace/models/Qwen3-0.6B`

### Manual Build

To manually trigger a build with a custom tag:

1. Go to **Actions** tab in your repository
2. Select **"Build and Push Docker Image to GHCR"**
3. Click **"Run workflow"**
4. Optionally enter a custom tag
5. Click **"Run workflow"**

### Local Build

To build the image locally:

```bash
# Build locally
docker build -t ghcr.io/warjiang/nano-vllm:local .

# Run locally
docker run --rm --gpus all \
  -v ~/huggingface:/workspace/models:ro \
  ghcr.io/warjiang/nano-vllm:local
```
