#!/bin/bash

set -xeuo pipefail

services=(
    "account"
    "customer"
    "helloworld"
    "orchestrator"
    "order"
    "shared"
)

for chart in "${services[@]}" ; do
    helm template ./app/${services} -f ./${services}/values-prd.yaml >| ./release/${services}.yaml
done
