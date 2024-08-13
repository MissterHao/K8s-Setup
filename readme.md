





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
kubectl apply -f configmap.yaml 
```



## Argo

之所以要設定 `configmap/argocd-cmd-params-cm` 是因為下面的問題：
1. `server.basehref: /argo`、`server.rootpath: /argo` 是因為 httproute 已經將我的網址路徑修改掉了，也就是說當我會將 `/argo/` 當作 `/` 轉入 argo 的 service 中，但是 argo 的網頁有塞了一行 `<base href='/'>` 也就代表說儘管我把 httproute 用了 `strip-route` 去除掉 httproute 的前綴也沒用，對於已經傳出來的網頁來說 rootpath 還是指向了 `/`，所以需要回到 argo 的設定值去修改 `/` 成 `/argo`

2. `server.insecure: "true"` 是因為我沒有自己簽證 tls ssl 簽證，所以我要讓 argo 不使用 ssl
3. `argocd repo add git@github.com:MissterHao/K8s-Setup.git --ssh-private-key-path ~/.ssh/henry_me_id_ed25519` 用來設定 private repository
