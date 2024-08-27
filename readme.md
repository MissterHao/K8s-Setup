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
kubectl apply -f ./argo/configmap.yaml
```

Install Prometheus

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl apply -f ./prometheus

helm install prometheus-mine prometheus-community/kube-prometheus-stack -n prometheus --set web.route-prefix="/prometheus"
```


Install Loki

```
helm install loki grafana/loki --namespace=monitoring --values loki/values.yaml
```


Install FluentBit

```bash
helm repo add fluent https://fluent.github.io/helm-charts
helm upgrade --install fluent-bit fluent/fluent-bit -n monitoring
```



# 解說

目前盡量把所有觀測用的服務都放到 `monitoring` 這個 namespace 底下


## Argo

之所以要設定 `configmap/argocd-cmd-params-cm` 是因為下面的問題：

1. `server.basehref: /argo`、`server.rootpath: /argo` 是因為 httproute 已經將我的網址路徑修改掉了，也就是說當我會將 `/argo/` 當作 `/` 轉入 argo 的 service 中，但是 argo 的網頁有塞了一行 `<base href='/'>` 也就代表說儘管我把 httproute 用了 `strip-route` 去除掉 httproute 的前綴也沒用，對於已經傳出來的網頁來說 rootpath 還是指向了 `/`，所以需要回到 argo 的設定值去修改 `/` 成 `/argo`
  參考資料：
  - https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/

2. `server.insecure: "true"` 是因為我沒有自己簽證 tls ssl 簽證，所以我要讓 argo 不使用 ssl
3. `argocd repo add git@github.com:MissterHao/K8s-Setup.git --ssh-private-key-path ~/.ssh/henry_me_id_ed25519` 用來設定 private repository

## Prometheus

預設帳號密碼： ( 這組帳號密碼會因為不同版本而有所不同 )
```
user: admin
pswd: prom-operator
```

在 DataSource 的地方可以設定要去哪裡拿資料顯示在畫面上
因為出發點是由 Prometheus Pod 本身，所以填寫 url 的時候不應該填寫 public url 而是直接寫 service.namespace:port 的方式就可以了，像是下面這樣：
```
http://loki.monitoring:3100
```
這是 monitoring namespace 底下的 loki svc

## FluentBit

裡面的 values.yaml 是使用 `helm show values fluent/fluent-bit > values.yaml` 的方式把所有預設的值 dump 出來的

根據不同的系統要有不同的變數設定
像是因為一開始練習的 server 是 UTC+8 的時間系統，所以送出去的時候會發現有下面這樣的錯誤
```
```
因此要在 `[PARSER]` 中加上 `Time_Offset +0800` 才可以讓時區一致
可參考：
- https://blog.yowko.com/grafana-loki-fluentbit/
- https://github.com/fluent/fluent-bit/issues/4206
- https://docs.fluentbit.io/manual/pipeline/outputs/loki  (官方資料)
