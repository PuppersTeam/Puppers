#!/bin/bash

# Updates the Base CI environment with our custom Base CI Image
echo "Updating Base CI environment..."

# Default Docker Registry Name
REGISTRY_URL="registry.gitlab.com"

# Automatically grab the group and repo name from the git remote and strip the un-needed components of the URL to get the gitlab group and repo name
REMOTE_URL=$(git remote get-url --all origin)
REMOTE_NAME=$(echo $REMOTE_URL | cut -d ":" -f 2 | sed -e "s/.git$//")
echo "Using Remote Url: ${REMOTE_URL}"
echo "Using Remote Name: ${REMOTE_NAME}"

# Set the docker container name contexts (these are customizable, but we'll most likely only ever use this for initial bootstrapping of the Base CI image)
CONTEXT="base"
VERSION="5"

# Construct the container name with a context and a version
CONTAINER_NAME="${REGISTRY_URL}/${REMOTE_NAME}/builders/${CONTEXT}:v${VERSION}"
echo "Using Container Name: ${CONTAINER_NAME}"

# Build the Base CI container
docker build \
  --no-cache \
  --squash \
  -t $CONTAINER_NAME \
  -f Dockerfile.base \
  .

# Push the Base CI container to the container registry
docker push $CONTAINER_NAME
