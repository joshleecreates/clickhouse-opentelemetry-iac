# 0. Ensure Adequate Resources in Docker Desktop

# 1. Create a talos cluster with extra disks
talosctl cluster create --memory-workers=8192 --workers=2

# 2. Install Volume Claim Provisioner with Customize
https://www.talos.dev/v1.7/kubernetes-guides/configuration/local-storage/
kustomize build | kubectl apply -f -

We can ignore the security warning. This is from the more restrictive policy that Talos does not enforce by default.

# Allow priveleged containers
kubectl label namespace monitoring pod-security.kubernetes.io/enforce=privileged
https://www.talos.dev/v1.7/kubernetes-guides/configuration/pod-security/

# Install metrics server
https://www.talos.dev/v1.7/kubernetes-guides/configuration/deploy-metrics-server/
kubectl apply -f https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
