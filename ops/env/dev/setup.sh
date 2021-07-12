#!/bin/bash

echo "Boostrapping Development Environment..."

./ops/env/dev/setup/setup_kind.sh

./ops/env/dev/setup/setup_ca.sh
