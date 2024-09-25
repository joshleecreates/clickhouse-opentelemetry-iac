# Clreate an EKS Cluster with ClickHouse®

## Legal

Altinity®, Altinity.Cloud®, and Altinity Stable® are registered trademarks of Altinity, Inc. ClickHouse® is a registered trademark of ClickHouse, Inc.; Altinity is not affiliated with or associated with ClickHouse, Inc.

## Step 1: Create a Cluster

In order to run the demo, you need a Kubernetes cluster with dynamic storage provisioning and the ability to create LoadBalancers. We can use the Altinity EKS Terraform Module for ClickHouse.

In the `infrastructure` directory run:

1. `tofu init` / `terraform init`
2. `tofu apply`

This will take a few minutes to create an EKS cluster with two node groups.

Once this completes, you will see a command to configure your local kubectl with
the cluster context. If you need this command again you can fetch it with: `tofu output`

You can also bring your own Kubernetes cluster. The following steps assume that you have kubeconfig installed and configured to point to your desired cluster.

## Step 2: Install ArgoCD

In the `bootstrap` directory, run `terraform init` and `terraform apply`. This will
use the Terraform Helm provider to create an ArgoCD release.

The terraform outputs include the ArgoCD LoadBalancer URL and the initial admin password.

You can fetch the password again with:

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Step 3: Install Apps with ArgoCD CLI

### Configuring the ArgoCD CLI

If you'd like to use the ArgoCD CLI instead of the UI, you can configure it with the 
command `argocd login --core` (assuming your kube context is still active).

Before using the CLI, you may wish to set your default namespace to `argocd`:

```
kubectl config set-context --current --namespace=argocd
```

To use your Kubernetes context to log in to ArgoCD:

```
argocd login --core
```

To deploy the initial app-of-apps:

```
argocd app create apps \
  --dest-namespace argocd \
  --dest-server https://kubernetes.default.svc \
  --repo https://github.com/joshleecreates/clickhouse-opentelemetry-iac.git \
  --path argo-apps/apps
```

Then we need to sync the app:

```
argocd app sync argocd/apps
```

## Connect

#### Grafana

Connect to Grafana:

```
kubectl port-forward -n monitoring services/monitoring-grafana 3000:80
```

```
kubectl port-forward -n argocd services/argocd-server 3001:80
```

You can then load Grafana in your browser at `http://locahost:3000` — there is no username or password.

#### ClickHouse

Connect to ClickHouse:

```
kubectl exec -n monitoring -it chi-monitoringdb-monitoring-0-0-0 -- clickhouse-client
```

# Query Cheat Sheet

(These queries require the metrics exporter which is not currently configured)
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


