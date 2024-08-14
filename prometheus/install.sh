

kubectl create ns prometheus

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus-mine prometheus-community/kube-prometheus-stack
