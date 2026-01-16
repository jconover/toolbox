#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Default values
TARGET_OS="ubuntu"
PROFILE="all"

# Argument parsing
if [ "$1" ]; then
    TARGET_OS="$1"
fi

if [ "$2" ]; then
    PROFILE="$2"
fi

# Determine Dockerfile and Image Name Base
case "$TARGET_OS" in
    fedora)
        DOCKERFILE="Dockerfile.fedora"
        IMAGE_BASE="devops-toolbox-fedora"
        ;;
    kali)
        DOCKERFILE="Dockerfile.kali"
        IMAGE_BASE="devops-toolbox-kali"
        ;;
    ubuntu)
        DOCKERFILE="Dockerfile"
        IMAGE_BASE="devops-toolbox"
        ;;
    *)
        echo "Unknown OS: $TARGET_OS"
        echo "Usage: ./build.sh [ubuntu|fedora|kali] [all|cloud|k8s|minimal]"
        exit 1
        ;;
esac

# Determine Build Args based on Profile
BUILD_ARGS=""
case "$PROFILE" in
    all)
        IMAGE_TAG="latest"
        BUILD_ARGS="--build-arg INSTALL_ALL=true"
        ;;
    cloud)
        IMAGE_TAG="cloud"
        BUILD_ARGS="--build-arg INSTALL_ALL=false --build-arg INSTALL_CLOUD_CLI=true"
        ;;
    k8s)
        IMAGE_TAG="k8s"
        BUILD_ARGS="--build-arg INSTALL_ALL=false --build-arg INSTALL_K8S_TOOLS=true"
        ;;
    minimal)
        IMAGE_TAG="minimal"
        BUILD_ARGS="--build-arg INSTALL_ALL=false"
        ;;
    *)
        echo "Unknown Profile: $PROFILE"
        echo "Usage: ./build.sh [ubuntu|fedora|kali] [all|cloud|k8s|minimal]"
        exit 1
        ;;
esac

FULL_IMAGE_NAME="$IMAGE_BASE:$IMAGE_TAG"

# Check for podman or docker
if command -v podman &> /dev/null; then
    CONTAINER_CMD="podman"
elif command -v docker &> /dev/null; then
    CONTAINER_CMD="docker"
else
    echo "Error: Neither podman nor docker found."
    exit 1
fi

echo "Building $FULL_IMAGE_NAME from $DOCKERFILE with $CONTAINER_CMD..."
echo "Profile: $PROFILE"
echo "Build Args: $BUILD_ARGS"

$CONTAINER_CMD build --platform linux/arm64 -t "$FULL_IMAGE_NAME" -f "$SCRIPT_DIR/$DOCKERFILE" $BUILD_ARGS "$SCRIPT_DIR"

echo "Build complete!"
echo "Run: ./toolbox.sh $TARGET_OS $PROFILE"
