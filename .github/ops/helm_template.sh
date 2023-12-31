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
    helm template ./app/${service} -f ./app/${service}/values-prd.yaml >| ./release/${service}.yaml
done
