# Asterisk on AKS (Azure Kubernetes Service)

This repository contains Kubernetes manifests to deploy a scalable Asterisk VoIP system on Azure Kubernetes Service (AKS) with persistent storage and vertical pod autoscaling.

## 📁 Files Included

| File                     | Description                                       |
|--------------------------|---------------------------------------------------|
| asterisk-config.yaml     | Kubernetes ConfigMap containing Asterisk configs |
| asterisk-deployment.yaml | Deployment of the Asterisk container             |
| asterisk-pvc.yaml        | PersistentVolumeClaim using Azure File Storage   |
| asterisk-service.yaml    | LoadBalancer service exposing SIP ports          |
| asterisk-vpa.yaml        | Vertical Pod Autoscaler configuration            |

---

## 🛠️ Prerequisites

- Azure CLI installed & logged in
- AKS cluster created and kubeconfig configured (`az aks get-credentials`)
- Helm installed
- kubectl installed
- Asterisk config files present in `./asterisk-configs` directory

---

## 🚀 Deployment Steps

### 1. Set namespace

```bash
kubectl create namespace asterisk
kubectl config set-context --current --namespace=asterisk
```

### 2. Enable Azure File CSI Driver (if not already)

```bash
az aks enable-addons --addons azure-files \
  --name <your-cluster-name> \
  --resource-group <your-resource-group>
```

⚠️ Skip if it's already working — verify with:

```bash
kubectl get sc
```

### 3. Apply Persistent Volume Claim

```bash
kubectl apply -f asterisk-pvc.yaml
```

### 4. Create Asterisk ConfigMap

Assuming your Asterisk config files (e.g., `pjsip.conf`, `extensions.conf`, etc.) are inside `./asterisk-configs/`

```bash
kubectl create configmap asterisk-config --from-file=asterisk-configs
```

### 5. Apply Deployment

```bash
kubectl apply -f asterisk-deployment.yaml
```

### 6. Apply LoadBalancer Service

```bash
kubectl apply -f asterisk-service.yaml
```

### 7. Install Vertical Pod Autoscaler (only once)

Install VPA via Helm:

```bash
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update
helm install vpa autoscaler/vertical-pod-autoscaler --namespace kube-system
```

Apply VPA object:

```bash
kubectl apply -f asterisk-vpa.yaml
```

### 8. Install Horizontal Pod Autoscaler (optional)

Apply HPA object:

```bash
kubectl apply -f hpa.yaml
```

---

## 🌐 Accessing Asterisk

To find the external IP:

```bash
kubectl get svc asterisk
```

Then access via SIP client (e.g., MicroSIP) on:

```
sip:<external-ip>:5060
```

---

## 📤 Cleanup

To remove all resources:

```bash
kubectl delete -f asterisk-vpa.yaml
kubectl delete -f hpa.yaml
kubectl delete -f asterisk-service.yaml
kubectl delete -f asterisk-deployment.yaml
kubectl delete configmap asterisk-config
kubectl delete -f asterisk-pvc.yaml
kubectl delete namespace asterisk
```

---

