#!/bin/bash

set -eo pipefail

CDK_OUTPUTS=infra/outputs.json
BUCKET_NAME=$(cat ${CDK_OUTPUTS} | jq -r .WebStorageBenchmarkStack.BucketName)
DISTRIBUTION_ID=$(cat ${CDK_OUTPUTS} | jq -r .WebStorageBenchmarkStack.CloudFrontDistributionId)

flutter build web

aws s3 sync build/web s3://$BUCKET_NAME --delete
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*" >/dev/null