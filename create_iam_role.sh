#!/bin/bash

# https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/associate-service-account-role.html

profile="tatsukoni"
region="ap-northeast-1"
cluster_name="eks-work-cluster"

account_id=$(aws sts get-caller-identity --query "Account" --output text --profile $profile --region $region)
oidc_provider=$(aws eks describe-cluster --name $cluster_name --profile $profile --region $region --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")

# サービスアカウント自体はservice-account.yamlで作成済
namespace="atlantis"
service_account="account-atlantis"

cat >trust-relationship.json <<EOF
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
          "$oidc_provider:sub": "system:serviceaccount:$namespace:$service_account"
        }
      }
    }
  ]
}
EOF

# IAM Roleを作成
iam_role_name="atlantis-role"
aws iam create-role \
  --role-name $iam_role_name \
  --assume-role-policy-document file://trust-relationship.json \
  --description "$iam_role_name" \
  --profile $profile \
  --region $region

# 割り当てたいポリシーをアタッチ
aws iam attach-role-policy \
  --role-name $iam_role_name \
  --policy-arn=arn:aws:iam::aws:policy/AdministratorAccess \
  --profile $profile \
  --region $region

# サービスアカウントに、サービスアカウントで引き受ける IAM ロールの Amazon リソースネーム (ARN) の注釈を付ける
kubectl annotate serviceaccount -n $namespace $service_account eks.amazonaws.com/role-arn=arn:aws:iam::083636136646:role/atlantis-role
