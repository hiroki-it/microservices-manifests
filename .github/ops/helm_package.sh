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
    helm package ./app/${service} -d ./archives
done
