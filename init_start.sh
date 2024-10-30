#!/bin/bash

# 名前空間作成
kubectl create -f atlantis-namespace.yaml
kubectl config set-context --current --namespace=atlantis

# サービスアカウント作成
kubectl apply -f service-account.yaml
# IAM Role はKubernetes外で作成済
kubectl annotate serviceaccount -n atlantis account-atlantis eks.amazonaws.com/role-arn=arn:aws:iam::083636136646:role/atlantis-role

# Amazon EKS アドオンをクラスターに追加
sh create_ebs_csi_driver_addon.sh
# 作成後、nodeに割り当てられたIAMロールに、AmazonEBSCSIDriverPolicyポリシーをアタッチする
# StorageClassを新設
kubectl apply -f storage-class.yaml

# helm repo 追加
# helm repo add eks-charts https://aws.github.io/eks-charts
# helm repo add runatlantis https://runatlantis.github.io/helm-charts

# helm install
helm install aws-load-balancer-controller eks-charts/aws-load-balancer-controller \
  -n atlantis \
  --set clusterName="eks-work-cluster" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=account-atlantis

helm install atlantis runatlantis/atlantis -f values.yaml
