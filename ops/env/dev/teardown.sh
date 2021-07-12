#!/bin/sh

# Adapted from:
# https://github.com/kubernetes-sigs/kind/commits/master/site/static/examples/kind-with-registry.sh
#
# Copyright 2020 The Kubernetes Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit

# XXX: Think on a way to make this not be hardcoded
cluster_name='puppers-ops'

reg_name='kind-registry'
reg_port='5000'

# Teardown Registry Container if it exists
running="$(
  docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true
)"

if [ "${running}" == 'true' ]; then
  cid="$(docker inspect -f '{{.ID}}' "${reg_name}")"
  echo "Stopping and deleting Kind Registry container..."
  docker stop $cid >/dev/null
  docker rm $cid >/dev/null
fi

echo "Deleting local Kind cluster..."
kind delete cluster --name=$cluster_name

echo "Deleting local development ca certs..."

CA_CERTS_FOLDER="$(pwd)/.certs"

# This requires mkcert to be installed/available
echo "${CA_CERTS_FOLDER}"

# The CAROOT env variable is used by mkcert to determine where to read/write files - Reference: https://github.com/FiloSottile/mkcert - investigate how to fix this
#CAROOT=${CA_CERTS_FOLDER}/dev mkcert -uninstall

rm -rf ${CA_CERTS_FOLDER}
