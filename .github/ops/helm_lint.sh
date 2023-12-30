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
    helm lint ./app/${service} -f ./${service}/values-prd.yaml --strict
done
