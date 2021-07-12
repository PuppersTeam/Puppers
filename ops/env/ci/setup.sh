#!/bin/bash

echo "Boostrapping CI Environment..."

./ops/env/ci/setup/setup_ci_base.sh

./ops/env/ci/setup/setup_secure_ci.sh
