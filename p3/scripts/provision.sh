#! /bin/bash

k3d cluster create sel-mars --api-port 6443 -p "80:80@loadbalancer" -p "443:443@loadbalancer"
kubectl create namespace argocd
kubectl -n argocd apply -f /home/ubuntu/p3/confs/argocd.yaml
sleep 5
echo "Waiting for ArgoCD to be ready..."
kubectl -n argocd wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server --timeout=300s
echo "ArgoCD is ready!"
kubectl -n argocd apply -f /home/ubuntu/p3/confs/argocd-ingress.yaml
PASSWORD=$(argocd admin initial-password -n argocd | head -n 1)
argocd login localhost --insecure --grpc-web --username admin --password "$PASSWORD"
kubectl create namespace dev
argocd app create wil-playground --repo https://github.com/soofiane262/sel-mars.git --path wil-playground --dest-namespace dev --dest-server https://kubernetes.default.svc --sync-policy auto --revision main
sleep 2
kubectl -n dev wait --for=condition=ready pod -l app=wil-playground
echo "Wil-playground is ready!"
kubectl -n dev port-forward svc/wil-playground 8888:8888 &
echo -e "ArgoCD password: \033[1;31m$PASSWORD\033[0m"
