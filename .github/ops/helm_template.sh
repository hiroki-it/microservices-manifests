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

for service in "${services[@]}" ; do
    helm template ./app/${service} -f ./${service}/values-prd.yaml >| ./release/${service}.yaml
done
