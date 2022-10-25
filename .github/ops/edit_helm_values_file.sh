#!/bin/bash

set -xeuo pipefail

sudo wget https://github.com/mikefarah/yq/releases/download/v4.22.1/yq_linux_amd64 -O /usr/bin/yq
sudo chmod +x /usr/bin/yq

charts=(
    "argocd"
    "kubernetes"
)

for chart in "${charts[@]}" ; do
    yq e -i '(.aws.accountId |="'${AWS_ACCOUNT_ID}'") | (.aws.region |="'${AWS_DEFAULT_REGION}'")' ./${chart}/values/prd.yaml
done
