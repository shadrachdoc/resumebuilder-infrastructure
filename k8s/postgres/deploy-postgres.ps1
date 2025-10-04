# PostgreSQL Deployment Script - PowerShell
# File: k8s/postgres/deploy-postgres.ps1

# Stop on errors
$ErrorActionPreference = "Stop"

# Variables
$NAMESPACE = "resumebuilder-dev"

# Colors
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Yellow }
function Write-Error-Custom { Write-Host $args -ForegroundColor Red }

Write-Success "========================================"
Write-Success "PostgreSQL Deployment Script"
Write-Success "========================================"
Write-Host ""

# Check if kubectl is available
try {
    kubectl version --client --short | Out-Null
} catch {
    Write-Error-Custom "Error: kubectl is not installed or not in PATH"
    exit 1
}

# Check if namespace exists
try {
    kubectl get namespace $NAMESPACE 2>&1 | Out-Null
} catch {
    Write-Error-Custom "Error: Namespace '$NAMESPACE' does not exist"
    Write-Info "Please create namespaces first: kubectl apply -f k8s/namespaces/namespaces.yaml"
    exit 1
}

Write-Info "Deploying PostgreSQL to namespace: $NAMESPACE"
Write-Host ""

# Deploy resources in order
Write-Info "[1/5] Creating Secret..."
kubectl apply -f postgres-secret.yaml
Write-Success "✓ Secret created"
Write-Host ""

Write-Info "[2/5] Creating ConfigMap..."
kubectl apply -f postgres-configmap.yaml
Write-Success "✓ ConfigMap created"
Write-Host ""

Write-Info "[3/5] Creating PersistentVolumeClaim..."
kubectl apply -f postgres-pvc.yaml
Write-Success "✓ PVC created"
Write-Host ""

Write-Info "[4/5] Creating StatefulSet..."
kubectl apply -f postgres-statefulset.yaml
Write-Success "✓ StatefulSet created"
Write-Host ""

Write-Info "[5/5] Creating Service..."
kubectl apply -f postgres-service.yaml
Write-Success "✓ Service created"
Write-Host ""

# Wait for pod to be ready
Write-Info "Waiting for PostgreSQL pod to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n $NAMESPACE --timeout=120s

Write-Host ""
Write-Success "========================================"
Write-Success "PostgreSQL Deployment Complete!"
Write-Success "========================================"
Write-Host ""

# Display status
Write-Info "Current Status:"
kubectl get all -n $NAMESPACE -l app=postgres

Write-Host ""
Write-Info "PVC Status:"
kubectl get pvc -n $NAMESPACE

Write-Host ""
Write-Success "========================================"
Write-Success "Quick Commands:"
Write-Success "========================================"
Write-Host ""

Write-Info "View logs:"
Write-Host "  kubectl logs -f postgres-0 -n $NAMESPACE"
Write-Host ""

Write-Info "Connect to database:"
Write-Host "  kubectl exec -it postgres-0 -n $NAMESPACE -- psql -U postgres"
Write-Host ""

Write-Info "Port forward to localhost:"
Write-Host "  kubectl port-forward -n $NAMESPACE svc/postgres-service 5432:5432"
Write-Host ""

Write-Info "Test connection:"
Write-Host "  kubectl run psql-test --rm -it --restart=Never ``"
Write-Host "    --namespace=$NAMESPACE ``"
Write-Host "    --image=postgres:15-alpine ``"
Write-Host "    --env=`"PGPASSWORD=resumeapp@123`" ``"
Write-Host "    -- psql -h postgres-service -U resumeapp -d resumebuilder_dev"
Write-Host ""

Write-Success "Deployment successful! ✓"