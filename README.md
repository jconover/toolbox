# DevOps Toolbox Container

A comprehensive, ARM64-optimized container environment consisting of essential DevOps, Cloud, and AI tools. Designed for modern Apple Silicon Macs but compatible with other ARM64 Linux environments.

## Included Tools

| Category | Tools |
|----------|-------|
| **Cloud** | `aws` (v2), `az` (Azure CLI), `terraform`, `gcloud` |
| **Kubernetes** | `kubectl`, `helm`, `eksctl`, `kubelogin` (AKS), `k9s`, `kubectl-ai` |
| **AI Agents** | `claude-code`, `gemini-cli` |
| **Development** | `ansible`, `gh` (GitHub CLI), `node` (v20), `python3`, `pipx` |
| **Utilities** | `curl`, `wget`, `jq`, `git`, `vim`, `nano` |

## Usage

### 1. Build the Image

You can choose between an **Ubuntu 24.04** (default) or **Fedora 43** base.

**Ubuntu (Default):**
```bash
./build.sh
```

**Fedora:**
```bash
./build.sh fedora
```

### 2. Run the Toolbox

The runner script (`toolbox.sh`) automatically mounts your current directory to `/workspace` and mounts your local credentials if they exist:
*   `~/.aws` -> `/root/.aws`
*   `~/.azure` -> `/root/.azure`
*   `~/.ssh` -> `/root/.ssh`
*   `~/.kube` -> `/root/.kube`
*   `~/.config/gcloud` -> `/root/.config/gcloud`

**Run (Default/Ubuntu):**
```bash
./toolbox.sh
```

**Run (Fedora):**
```bash
./toolbox.sh fedora
```

## AI Tools Setup

*   **Claude Code**: Run `claude login` inside the container to authenticate.
*   **Gemini CLI**: Ensure you have your API key set up (usually via `GEMINI_API_KEY` env var or config).
*   **kubectl-ai**: Ensure `OPENAI_API_KEY` or `GEMINI_API_KEY` is set depending on your backend configuration, or configure it via `kubectl-ai` flags.
