1. `tofu init` / `terraform init`
2. `tofu apply`

# Argo

1. `kubectl config set-context --current --namespace=argocd`
2. 

```
argocd app create apps \
    --dest-namespace argocd \
    --dest-server https://kubernetes.default.svc \
  --repo https://github.com/joshleecreates/clickhouse-opentelemetry-iac.git \
  --path argo-apps
```

```
kubectl get secret clickhouse-credentials --namespace=clickhouse -oyaml | grep -v '^\s*namespace:\s' | kubectl apply --namespace=default -f -
```
