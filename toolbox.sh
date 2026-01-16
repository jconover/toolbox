#!/bin/bash
set -e

IMAGE_NAME="devops-toolbox"

if [ "$1" == "fedora" ]; then
    IMAGE_NAME="devops-toolbox-fedora"
    shift # Remove 'fedora' from args so we can pass the rest to the container
fi

# 1. Detect Container Engine
if command -v podman &> /dev/null; then
    CMD="podman"
    # Podman on Mac often needs explicit platform or machine start, but standard run usually works if machine is up.
    # We add --userns=keep-id if using rootless on linux, but on Mac it's complicated by the VM. 
    # Usually standard run is fine.
    OPTS="--platform linux/arm64"
elif command -v docker &> /dev/null; then
    CMD="docker"
    OPTS="--platform linux/arm64"
else
    echo "Error: Neither podman nor docker found."
    exit 1
fi

# 2. Determine Mounts
# We want to mount the current directory to /workspace
# And mount standard credential paths if they exist
MOUNTS="-v $(pwd):/workspace"

if [ -d "$HOME/.aws" ]; then
    MOUNTS="$MOUNTS -v $HOME/.aws:/root/.aws"
fi

if [ -d "$HOME/.ssh" ]; then
    MOUNTS="$MOUNTS -v $HOME/.ssh:/root/.ssh"
fi

if [ -d "$HOME/.kube" ]; then
    MOUNTS="$MOUNTS -v $HOME/.kube:/root/.kube"
fi

if [ -d "$HOME/.config/gcloud" ]; then
    MOUNTS="$MOUNTS -v $HOME/.config/gcloud:/root/.config/gcloud"
fi

if [ -d "$HOME/.azure" ]; then
    MOUNTS="$MOUNTS -v $HOME/.azure:/root/.azure"
fi

# 3. Run
echo "Starting DevOps Toolbox ($CMD)..."
echo "Mounting: $(pwd) -> /workspace"

# Interactive mode
# --rm to clean up after exit
# -it for interactive shell
# --network host (optional, but good for local dev servers, though on Mac host net is restricted in VM)
# We typically don't need --network host for CLI tools unless running servers.

$CMD run --rm -it $OPTS $MOUNTS \
    -e AWS_PROFILE \
    -e AWS_REGION \
    -w /workspace \
    "$IMAGE_NAME" "$@"
