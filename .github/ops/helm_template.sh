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
    helm template prd ./${chart} >| ./release/prd/${chart}/${chart}.yaml
done
