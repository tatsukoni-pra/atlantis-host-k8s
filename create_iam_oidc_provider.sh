#!/bin/bash

# https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/enable-iam-roles-for-service-accounts.html

cluster_name="eks-work-cluster"

# 既に作成済かどうか確認する
oidc_id=$(aws eks describe-cluster --name $cluster_name --profile tatsukoni --region ap-northeast-1 --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
is_exists=$(aws iam list-open-id-connect-providers --profile tatsukoni --region ap-northeast-1 | grep $oidc_id | cut -d "/" -f4)
if [ -n "$is_exists" ]; then
  echo "OIDC ID プロバイダーは既に作成済です"
  exit 0
fi

# クラスターの IAM OIDC ID プロバイダーを作成
eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve --profile tatsukoni --region ap-northeast-1
