#!/bin/bash

# helm repo add eks-charts https://aws.github.io/eks-charts

# helm repo add runatlantis https://runatlantis.github.io/helm-charts

helm install aws-load-balancer-controller eks-charts/aws-load-balancer-controller \
  -n atlantis \
  --set clusterName="eks-work-cluster" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=account-atlantis

helm install atlantis runatlantis/atlantis -f values.yaml
