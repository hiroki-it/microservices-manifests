#!/bin/bash

echo "AWS_ACCOUT_ID=${{ inputs.aws_account_id }}"
echo "AWS_DEFAULT_REGION=${{ inputs.aws_default_region }}"
echo "AWS_ECR_ACCOUNT_URL=${{ inputs.aws_account_id }}.dkr.ecr.${{ inputs.aws_default_region }}.amazonaws.com"
