#!/bin/bash

# https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/creating-an-add-on.html

eksctl create addon \
  --cluster eks-work-cluster \
  --name aws-ebs-csi-driver \
  --version latest \
  --service-account-role-arn arn:aws:iam::083636136646:role/AmazonEKS_EBS_CSI_DriverRole \
  --profile tatsukoni \
  --region ap-northeast-1
