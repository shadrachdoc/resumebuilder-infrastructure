# PostgreSQL Helm Chart - Complete Setup Guide

## 📁 Folder Structure

Create this exact structure in your `resumebuilder-infrastructure` repository:

```
resumebuilder-infrastructure/
├── helm/
│   └── postgres/
│       ├── Chart.yaml                    # Helm chart metadata
│       ├── .helmignore                   # Files to exclude
│       ├── values.yaml                   # Dev environment values
│       ├── values-staging.yaml           # Staging values
│       ├── values-production.yaml        # Production values
│       ├── README.md                     # Documentation
│       ├── deploy-postgres.ps1           # Deployment script
│       ├── validate-chart.ps1            # Validation script
│       └── templates/
│           ├── secret.yaml               # Database credentials template
│           ├── configmap.yaml            # Configuration template
│           ├── pvc.yaml                  # Storage template
│           ├── statefulset.yaml          # PostgreSQL deployment template
│           └── service.yaml              # Service template
└── k8s/
    └── namespaces/
        └── namespaces.yaml               # (Already created)
```

---

## 🚀 Step-by-Step Setup

### Step 1: Create Folder Structure

```powershell
cd resumebuilder-infrastructure
mkdir -p helm/postgres/templates
```

### Step 2: Copy All Files

Copy the content from each artifact I created above to these files:

1. `helm/postgres/Chart.yaml`
2. `helm/postgres/.helmignore`
3. `helm/postgres/values.yaml`
4. `helm/postgres/values-staging.yaml`
5. `helm/postgres/values-production.yaml`
6. `helm/postgres/README.md`
7. `helm/postgres/deploy-postgres.ps1`
8. `helm/postgres/validate-chart.ps1`
9. `helm/postgres/templates/secret.yaml`
10. `helm/postgres/templates/configmap.yaml`
11. `helm/postgres/templates/pvc.yaml`
12. `helm/postgres/templates/statefulset.yaml`
13. `helm/postgres/templates/service.yaml`

### Step 3: Install Helm (if not already)

**Check if Helm is installed:**
```powershell
helm version
```

**If not installed, install using Chocolatey:**
```powershell
choco install kubernetes-helm
```

**Or download from:** https://github.com/helm/helm/releases

### Step 4: Validate the Helm Chart

```powershell
cd resumebuilder-infrastructure/helm/postgres
.\validate-chart.ps1 -Environment dev
```

This will:
- Lint the chart
- Check all files exist
- Render templates (dry-run)

### Step 5: Deploy PostgreSQL

**Development:**
```powershell
.\deploy-postgres.ps1 -Environment dev
```

**Staging:**
```powershell
.\deploy-postgres.ps1 -Environment staging
```

**Production:**
```powershell
.\deploy-postgres.ps1 -Environment production
```

### Step 6: Verify Deployment

```powershell
# Check Helm release
helm list -n resumebuilder-dev

# Check Kubernetes resources
kubectl get all -n resumebuilder-dev

# Check logs
kubectl logs -f postgres-service-0 -n resumebuilder-dev
```

---

## 🧪 Testing

### Test Connection

**Method 1: Port Forward**
```powershell
# Open first terminal
kubectl port-forward -n resumebuilder-dev svc/postgres-service 5432:5432

# Open second terminal with psql installed
psql -h localhost -U resumeapp -d resumebuilder_dev
# Password: resumeapp@123
```

**Method 2: Inside Pod**
```powershell
kubectl exec -it postgres-service-0 -n resumebuilder-dev -- psql -U postgres

# Inside psql:
\l                          # List databases
\c resumebuilder_dev        # Connect to app database
\dt                         # List tables
\q                          # Quit
```

---

## 🔄 Common Operations

### Upgrade (after changing values)

```powershell
.\deploy-postgres.ps1 -Environment dev
# Script automatically detects existing release and upgrades
```

### View Helm History

```powershell
helm history postgres-dev -n resumebuilder-dev
```

### Rollback to Previous Version

```powershell
helm rollback postgres-dev 1 -n resumebuilder-dev
```

### Uninstall

```powershell
helm uninstall postgres-dev -n resumebuilder-dev
```

---

## 📊 Monitoring

### Resource Usage

```powershell
kubectl top pod postgres-service-0 -n resumebuilder-dev
```

### Live Logs

```powershell
kubectl logs -f postgres-service-0 -n resumebuilder-dev
```

### Pod Status

```powershell
kubectl get pods -n resumebuilder-dev -w
```

---

## 🔧 Customization

### Modify Values

Edit `values.yaml` for development:

```yaml
# Example: Increase storage
persistence:
  size: 20Gi

# Example: Change resources
resources:
  requests:
    memory: "512Mi"
```

### Apply Changes

```powershell
.\deploy-postgres.ps1 -Environment dev
```

---

## ⚠️ Troubleshooting

### Chart Validation Fails

```powershell
# Check syntax
helm lint ./helm/postgres

# Debug template rendering
helm template test ./helm/postgres --debug
```

### Pod Not Starting

```powershell
kubectl describe pod postgres-service-0 -n resumebuilder-dev
kubectl get events -n resumebuilder-dev --sort-by='.lastTimestamp'
```

### PVC Not Binding

```powershell
kubectl get pvc -n resumebuilder-dev
kubectl describe pvc postgres-service-pvc -n resumebuilder-dev
```

---

## 🎯 Next Steps

After PostgreSQL is running:

1. ✅ **Create Redis Helm chart** (similar structure)
2. ✅ **Create Backend API Helm chart** (Laravel)
3. ✅ **Create Frontend Helm chart** (React)
4. ✅ **Setup ArgoCD** for automated deployments
5. ✅ **Create Terraform** for AKS provisioning

---

## 📝 Git Commit

After creating all files:

```powershell
git add helm/postgres/
git commit -m "feat: add PostgreSQL Helm chart with multi-environment support"
git push origin develop
```

---

## ✅ Checklist

Before marking ticket as complete:

- [ ] All 13 files created in correct locations
- [ ] Helm installed and verified (`helm version`)
- [ ] Chart validated (`.\validate-chart.ps1`)
- [ ] Deployed to dev environment (`.\deploy-postgres.ps1`)
- [ ] Verified pod is running
- [ ] Tested database connection
- [ ] Checked logs for errors
- [ ] Committed to Git
- [ ] Updated GitHub Projects board

---

## 🔒 Security Note

**For Production:**
- Change all default passwords
- Use Azure Key Vault for secrets
- Enable SSL/TLS
- Configure network policies
- Setup automated backups

---

## 📚 Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [PostgreSQL on Kubernetes](https://www.postgresql.org/docs/15/)