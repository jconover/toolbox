#!/bin/bash
set -e

# Default values
TARGET_OS="ubuntu"
PROFILE="all"

# Argument parsing logic to handle optional args
# Usage: ./toolbox.sh [os] [profile] [extra_cmd_args...]

if [[ "$1" == "ubuntu" || "$1" == "fedora" || "$1" == "kali" ]]; then
    TARGET_OS="$1"
    shift
fi

if [[ "$1" == "all" || "$1" == "cloud" || "$1" == "k8s" || "$1" == "minimal" ]]; then
    PROFILE="$1"
    shift
fi

# Determine Image Name
case "$TARGET_OS" in
    fedora)
        IMAGE_BASE="devops-toolbox-fedora"
        ;;
    kali)
        IMAGE_BASE="devops-toolbox-kali"
        ;;
    ubuntu)
        IMAGE_BASE="devops-toolbox"
        ;;
esac

case "$PROFILE" in
    all) IMAGE_TAG="latest" ;;
    cloud) IMAGE_TAG="cloud" ;;
    k8s) IMAGE_TAG="k8s" ;;
    minimal) IMAGE_TAG="minimal" ;;
    *) IMAGE_TAG="latest" ;; # Fallback
esac

FULL_IMAGE_NAME="$IMAGE_BASE:$IMAGE_TAG"

# 1. Detect Container Engine
if command -v podman &> /dev/null; then
    CMD="podman"
    # Podman options
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
echo "Image: $FULL_IMAGE_NAME"
echo "Mounting: $(pwd) -> /workspace"

# Interactive mode
# --rm to clean up after exit
# -it for interactive shell

$CMD run --rm -it $OPTS $MOUNTS \
    -e AWS_PROFILE \
    -e AWS_REGION \
    -w /workspace \
    "$FULL_IMAGE_NAME" "$@"
