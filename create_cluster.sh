#!/bin/bash

eksctl create cluster \
  --name eks-work-cluster \
  --region ap-northeast-1 \
  --version 1.30 \
  --nodegroup-name eks-work-nodegroup \
  --node-type t3.small \
  --nodes 1 \
  --nodes-min 1 \
  --nodes-max 1 \
  --vpc-public-subnets subnet-0043c72cfb2b9bc77,subnet-0b59531acff265d5d \
  --profile tatsukoni
