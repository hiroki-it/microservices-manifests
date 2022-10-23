#!/bin/bash

set -xeuo pipefail

charts=(
    "argocd"
    "eks"
    "istio"
    "istio-operator"
    "kubernetes"
)

for chart in "${charts[@]}" ; do
    helm lint ./${chart} -f ./${chart}/values/prd.yaml --strict
done
