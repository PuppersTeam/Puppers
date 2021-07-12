#!/bin/bash

INGRESS_CONFIG_PATH=$BASE_DIR/ops/release-ingress.yml

$BASE_DIR/ops/env/ci/helpers/apply_ingress.sh \
    $INGRESS_CONFIG_PATH \
    generated_ingress_config
