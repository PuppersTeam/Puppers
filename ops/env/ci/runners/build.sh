#!/bin/bash

set -e

echo ""
echo "================================================================="
echo ""
echo "Building Image..."
echo ""
echo "================================================================="
echo ""

# XXX: Think on a way to improve this
function sha256sum() { openssl sha256 "${@}" | awk '{print $2}'; }

TAG=$1
BUILDER=$2
VERSION_FILE=$3
BUILD_TARGET=$4

# XXX: Think on a way to simplify this
VERSION_HASH=$(sha256sum $VERSION_FILE)
VERSION_HASH=${VERSION_HASH::8}
echo "VERSION_HASH: ${VERSION_HASH}"

BUILDER_IMAGE="${BUILDER}:${VERSION_HASH}"
echo "BUILDER_IMAGE: ${BUILDER_IMAGE}"

echo "Using the following Dockerfile:"
cat ./ops/Dockerfile.build

# Build and push the image to our repo
docker build \
    -t $TAG \
    -f ./ops/Dockerfile.build \
    --target=$BUILD_TARGET \
    --build-arg "BUILDER_IMAGE=${BUILDER_IMAGE}" \
    .

docker push $TAG
