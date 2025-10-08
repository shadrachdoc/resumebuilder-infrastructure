# PostgreSQL Helm Chart

This Helm chart deploys PostgreSQL 15 to Kubernetes with support for multiple environments.

## 📋 Prerequisites

- Kubernetes cluster (Docker Desktop K8s or AKS)
- Helm 3.x installed
- kubectl configured
- Namespaces created

## 🚀 Quick Start

### Install Helm (if not already installed)

**Windows (PowerShell):**
```powershell
choco install kubernetes-helm
# OR download from https://github.com/helm/helm/releases
```

**Verify Helm installation:**
```powershell
helm version
```

### Deploy PostgreSQL

**Development Environment:**
```powershell
# From resumebuilder-infrastructure directory
helm install postgres-dev ./helm/postgres `
  --namespace resumebuilder-dev `
  --values ./helm/postgres/values.yaml
```

**Staging Environment:**
```powershell
helm install postgres-staging ./helm/postgres `
  --namespace resumebuilder-staging `
  --values ./helm/postgres/values-staging.yaml
```

**Production Environment:**
```powershell
helm install postgres-production ./helm/postgres `
  --namespace resumebuilder-production `
  --values ./helm/postgres/values-production.yaml
```

---

## 📊 Verify Deployment

```powershell
# Check Helm releases
helm list -n resumebuilder-dev

# Check Kubernetes resources
kubectl get all -n resumebuilder-dev -l app=postgres

# Check PVC
kubectl get pvc -n resumebuilder-dev

# Check logs
kubectl logs -f postgres-service-0 -n resumebuilder-dev
```

---

## 🔄 Upgrade Deployment

After modifying values:

```powershell
helm upgrade postgres-dev ./helm/postgres `
  --namespace resumebuilder-dev `
  --values ./helm/postgres/values.yaml
```

---

## 🗑️ Uninstall

```powershell
# Uninstall release (keeps PVC)
helm uninstall postgres-dev -n resumebuilder-dev

# Delete PVC manually if needed
kubectl delete pvc postgres-service-pvc -n resumebuilder-dev
```

---

## 🔌 Connect to PostgreSQL

### Port Forward

```powershell
kubectl port-forward -n resumebuilder-dev svc/postgres-service 5432:5432
```

### Connect with psql

```powershell
# Using kubectl exec
kubectl exec -it postgres-service-0 -n resumebuilder-dev -- psql -U postgres

# Using local psql (after port-forward)
psql -h localhost -U resumeapp -d resumebuilder_dev
# Password: resumeapp@123
```

---

## ⚙️ Configuration

### Values Files

| File | Environment | Purpose |
|------|-------------|---------|
| `values.yaml` | Development | Default dev settings |
| `values-staging.yaml` | Staging | Staging overrides |
| `values-production.yaml` | Production | Production overrides |

### Key Configuration Options

```yaml
# Namespace
namespace: resumebuilder-dev

# Image
image:
  repository: postgres
  tag: "15-alpine"

# Resources
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"

# Storage
persistence:
  size: 10Gi
  storageClass: "hostpath"

# Database credentials
postgresql:
  superuser:
    username: postgres
    password: postgres@123
  appuser:
    username: resumeapp
    password: resumeapp@123
```

---

## 🔒 Security Best Practices

### ⚠️ Production Checklist

- [ ] Change default passwords
- [ ] Use Azure Key Vault for secrets
- [ ] Enable SSL/TLS connections
- [ ] Configure network policies
- [ ] Setup automated backups
- [ ] Enable audit logging
- [ ] Use managed-premium storage class
- [ ] Configure proper resource limits

### Using External Secrets (Production)

For production, integrate with Azure Key Vault:

```yaml
# In values-production.yaml (future enhancement)
externalSecrets:
  enabled: true
  keyVault: resumebuilder-keyvault
  secrets:
    - postgres-password
    - app-password
```

---

## 🧪 Testing

### Dry Run (Preview changes)

```powershell
helm install postgres-dev ./helm/postgres `
  --namespace resumebuilder-dev `
  --values ./helm/postgres/values.yaml `
  --dry-run --debug
```

### Template Rendering

```powershell
helm template postgres-dev ./helm/postgres `
  --values ./helm/postgres/values.yaml
```

---

## 📈 Monitoring

### Get Resource Usage

```powershell
kubectl top pod postgres-service-0 -n resumebuilder-dev
```

### Watch Pod Status

```powershell
kubectl get pods -n resumebuilder-dev -w
```

---

## 🛠️ Troubleshooting

### Pod Not Starting

```powershell
# Describe pod
kubectl describe pod postgres-service-0 -n resumebuilder-dev

# Check events
kubectl get events -n resumebuilder-dev --sort-by='.lastTimestamp'
```

### Storage Issues

```powershell
# Check PVC status
kubectl get pvc -n resumebuilder-dev

# Check PV
kubectl get pv
```

### Connection Issues

```powershell
# Test DNS resolution
kubectl run test-dns --rm -it --restart=Never `
  --image=busybox `
  --namespace=resumebuilder-dev `
  -- nslookup postgres-service
```

---

## 📚 Helm Chart Structure

```
helm/postgres/
├── Chart.yaml                    # Chart metadata
├── values.yaml                   # Default values (dev)
├── values-staging.yaml           # Staging values
├── values-production.yaml        # Production values
├── templates/
│   ├── secret.yaml              # Database credentials
│   ├── configmap.yaml           # Configuration
│   ├── pvc.yaml                 # Persistent storage
│   ├── statefulset.yaml         # PostgreSQL deployment
│   └── service.yaml             # Service definition
└── README.md                    # This file
```

---

## 🎯 Next Steps

After PostgreSQL is deployed:

1. ✅ Deploy Redis Helm chart
2. ✅ Deploy Backend API Helm chart
3. ✅ Deploy Frontend Helm chart
4. ✅ Setup ArgoCD for GitOps
5. ✅ Configure Terraform for AKS

---

## 📖 References

- [Helm Documentation](https://helm.sh/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/15/)
- [Kubernetes StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)