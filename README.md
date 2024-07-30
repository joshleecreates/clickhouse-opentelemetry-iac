# Clreate an EKS Cluster with ClickHouse

## Install Infrastructure

In the `infrastructure` directory:

1. `tofu init` / `terraform init`
2. `tofu apply`

This will take a few minutes to create an EKS cluster with two node groups.

Once this completes, you will see a command to configure your local kubectl with
the cluster context. If you need this command again you can fetch it with: `tofu output`

## Bootstrap ArgoCD

In the `bootstrap` directory, run `terraform init` and `terraform apply`. This will
use the terraform helm provider to create an ArgoCD release.

The terraform outputs include the ArgoCD LoadBalancer URL and the initial admin password.

You can see the unredacted password with `tofu outputs -json`.

### Configuring the ArgoCD CLI

If you'd like to use the ArgoCD CLI instead of the UI, you can configure it with the 
command `argocd login --core` (assuming your kube context is still active).

Before using the CLI, you may wish to set your default namespace to `argocd`:

```
kubectl config set-context --current --namespace=argocd
```




---

Once the cluster has been created, you can fetch the admin password using this command:

```
kubectl get secret clickhouse-credentials --namespace=clickhouse -oyaml | grep -v '^\s*namespace:\s' | kubectl apply --namespace=default -f -
```

And you can get the ingress address with:

```
kubectl get service -n clickhouse clickhouse-eks -o jsonpath="{.status.loadBalancer.ingress}"
```

# Deploy App-of-Apps with ArgoCD

We'll use ArgoCD to deploy our app-of-apps chart, which is defined in `/argo-apps`.

`kubectl config set-context --current --namespace=argocd`

```
argocd app create apps \
    --dest-namespace argocd \
    --dest-server https://kubernetes.default.svc \
  --repo https://github.com/joshleecreates/clickhouse-opentelemetry-iac.git \
  --path argo-apps
```

```
argocd app sync argocd/apps
```

We can use this command to get the ArgoCD admin password and watch our apps deploy:

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

- get argocd server URL
- configure argocd cli tool with kubernetes API access
- port forwarding

## Create Secrets

### Configure Grafana

#### Create a Grafana Admin User

```
kubectl create secret generic grafana-admin \
  --from-literal=admin-user=YWRtaW4= \
  --from-literal=admin-password=cGFzc3dvcmQ=
```

#### Create a READ-ONLY ClickHouse User

#### Provide the Credentials to Grafana
Create secrete 'grafana-env-secret'

# Query Cheat Sheet

#### Get all nodes

```
SELECT DISTINCT ResourceAttributes['k8s.node.name'] AS distinct_values
	FROM otel.otel_metrics_sum
	WHERE "MetricName"='k8s.node.cpu.time' 
	AND ResourceAttributes['k8s.node.name'] IS NOT NULL;
```

#### Get all pods (with node name)

```
SELECT DISTINCT ResourceAttributes['k8s.pod.uid'] AS uid, ResourceAttributes['k8s.pod.name'] as name, ResourceAttributes['k8s.node.name'] AS node
	FROM otel.otel_metrics_sum
	WHERE "MetricName"='k8s.pod.cpu.time' 
	AND ResourceAttributes['k8s.pod.uid'] IS NOT NULL;
```

#### Get all pods (with node and service name)

```
SELECT 
	DISTINCT ResourceAttributes['k8s.pod.uid'] AS uid, 
	ResourceAttributes['k8s.pod.name'] as name, 
	ResourceAttributes['k8s.node.name'] AS node,
	multiIf(
		has(mapKeys("ResourceAttributes"), 'k8s.deployment.name'), ResourceAttributes['k8s.deployment.name'],
		has(mapKeys("ResourceAttributes"), 'k8s.statefulset.name'), ResourceAttributes['k8s.statefulset.name'],
		has(mapKeys("ResourceAttributes"), 'k8s.daemonset.name'), ResourceAttributes['k8s.daemonset.name'],
		'unknown'
	) AS service_name
FROM otel.otel_metrics_sum
WHERE "MetricName"='k8s.pod.cpu.time' 
	AND ResourceAttributes['k8s.pod.uid'] IS NOT NULL;
```
