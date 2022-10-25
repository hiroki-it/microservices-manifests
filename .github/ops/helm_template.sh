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
    helm template ./${chart} -f ./${chart}/values/prd.yaml >| ./release/prd/${chart}/${chart}.yaml
done
