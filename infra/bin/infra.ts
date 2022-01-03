#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { WebStorageBenchmarkStack } from '../lib/infra-stack';

const app = new cdk.App();
new WebStorageBenchmarkStack(app, 'WebStorageBenchmarkStack', {
  env: { 
    account: process.env.CDK_DEFAULT_ACCOUNT, 
    region: process.env.CDK_DEFAULT_REGION,
   }
});