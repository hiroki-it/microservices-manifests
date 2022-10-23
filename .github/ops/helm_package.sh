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
    helm package ./${chart} -d ./archives
done
