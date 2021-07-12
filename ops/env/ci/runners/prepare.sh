#!/bin/bash

set -e

echo ""
echo "================================================================="
echo ""
echo "Preparing Builder Image..."
echo ""
echo "================================================================="
echo ""

# XXX: Think on a way to improve this
function sha256sum() { openssl sha256 "${@}" | awk '{print $2}'; }

BUILDER=$1
echo "BUILDER: ${BUILDER}"

VERSION_FILE=$2
echo "VERSION_FILE: ${VERSION_FILE}"

# XXX: Think on a way to simplify this
VERSION_HASH=$(sha256sum $VERSION_FILE)
VERSION_HASH=${VERSION_HASH::8}
echo "VERSION_HASH: ${VERSION_HASH}"

BUILDER_IMAGE="${BUILDER}:${VERSION_HASH}"
echo "BUILDER_IMAGE: ${BUILDER_IMAGE}"

echo "Using the following Dockerfile:"
cat ./ops/Dockerfile.deps

# Prepare the Builder Image
if ! docker pull $BUILDER_IMAGE; then
  echo "Preparing Builder Image... ${BUILDER_IMAGE}"
  docker build \
      -t $BUILDER_IMAGE \
      -f ./ops/Dockerfile.deps \
      .

  docker push $BUILDER_IMAGE
fi
