#!/bin/bash

# https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/ebs-csi.html

profile="tatsukoni"
region="ap-northeast-1"
cluster_name="eks-work-cluster"

account_id=$(aws sts get-caller-identity --query "Account" --output text --profile $profile --region $region)
oidc_provider=$(aws eks describe-cluster --name $cluster_name --profile $profile --region $region --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")

cat >aws-ebs-csi-driver-trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$account_id:oidc-provider/$oidc_provider"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "$oidc_provider:aud": "sts.amazonaws.com",
          "$oidc_provider:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF

# IAM Roleを作成
iam_role_name="AmazonEKS_EBS_CSI_DriverRole"
aws iam create-role \
  --role-name $iam_role_name \
  --assume-role-policy-document file://"aws-ebs-csi-driver-trust-policy.json" \
  --description "$iam_role_name" \
  --profile $profile \
  --region $region

# ポリシーをアタッチ
aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --profile $profile \
  --region $region
