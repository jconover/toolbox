#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
IMAGE_NAME="devops-toolbox"

# Check for podman or docker
if command -v podman &> /dev/null; then
    CONTAINER_CMD="podman"
elif command -v docker &> /dev/null; then
    CONTAINER_CMD="docker"
else
    echo "Error: Neither podman nor docker found."
    exit 1
fi

if [ "$1" == "fedora" ]; then
    DOCKERFILE="Dockerfile.fedora"
    IMAGE_NAME="devops-toolbox-fedora"
else
    DOCKERFILE="Dockerfile"
    IMAGE_NAME="devops-toolbox"
fi

echo "Building $IMAGE_NAME from $DOCKERFILE with $CONTAINER_CMD..."
$CONTAINER_CMD build --platform linux/arm64 -t "$IMAGE_NAME" -f "$SCRIPT_DIR/$DOCKERFILE" "$SCRIPT_DIR"

echo "Build complete! Run ./toolbox.sh [base] to start."
