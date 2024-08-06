





# Installation 


Install gateway-api
```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
```

Install Kong
```bash
helm repo add kong https://charts.konghq.com
helm repo update

helm install kong kong/ingress -n kong --create-namespace
```

Install Argo
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

