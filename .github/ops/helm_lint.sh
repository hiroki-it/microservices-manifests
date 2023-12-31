#!/bin/bash

set -xeuo pipefail

services=(
    "account"
    "curl"
    "customer"
    "helloworld"
    "httpbin"
    "orchestrator"
    "order"
    "shared"
)

for service in "${services[@]}" ; do
    helm lint ./app/${service} -f ./app/${service}/values-prd.yaml --strict
done
