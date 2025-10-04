# PostgreSQL Helm Deployment Script - PowerShell
# File: helm/postgres/deploy-postgres.ps1

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('dev', 'staging', 'production')]
    [string]$Environment = 'dev'
)

# Stop on errors
$ErrorActionPreference = "Stop"

# Colors
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Yellow }
function Write-Error-Custom { Write-Host $args -ForegroundColor Red }

Write-Success "========================================"
Write-Success "PostgreSQL Helm Deployment"
Write-Success "========================================"
Write-Host ""

# Check if Helm is installed
try {
    $helmVersion = helm version --short 2>&1
    Write-Info "Helm Version: $helmVersion"
} catch {
    Write-Error-Custom "Error: Helm is not installed"
    Write-Info "Install Helm: choco install kubernetes-helm"
    Write-Info "Or download from: https://github.com/helm/helm/releases"
    exit 1
}

# Check if kubectl is available
try {
    kubectl version --client --short | Out-Null
} catch {
    Write-Error-Custom "Error: kubectl is not installed or not in PATH"
    exit 1
}

# Set environment-specific variables
switch ($Environment) {
    'dev' {
        $NAMESPACE = "resumebuilder-dev"
        $RELEASE_NAME = "postgres-dev"
        $VALUES_FILE = "values.yaml"
    }
    'staging' {
        $NAMESPACE = "resumebuilder-staging"
        $RELEASE_NAME = "postgres-staging"
        $VALUES_FILE = "values-staging.yaml"
    }
    'production' {
        $NAMESPACE = "resumebuilder-production"
        $RELEASE_NAME = "postgres-production"
        $VALUES_FILE = "values-production.yaml"
    }
}

Write-Info "Environment: $Environment"
Write-Info "Namespace: $NAMESPACE"
Write-Info "Release Name: $RELEASE_NAME"
Write-Info "Values File: $VALUES_FILE"
Write-Host ""

# Check if namespace exists
try {
    kubectl get namespace $NAMESPACE 2>&1 | Out-Null
} catch {
    Write-Error-Custom "Error: Namespace '$NAMESPACE' does not exist"
    Write-Info "Please create namespaces first: kubectl apply -f k8s/namespaces/namespaces.yaml"
    exit 1
}

# Check if Helm release already exists
$releaseExists = $false
try {
    $releases = helm list -n $NAMESPACE -o json | ConvertFrom-Json
    $releaseExists = $releases | Where-Object { $_.name -eq $RELEASE_NAME }
} catch {
    # Release doesn't exist, continue
}

if ($releaseExists) {
    Write-Info "Release '$RELEASE_NAME' already exists. Upgrading..."
    Write-Host ""
    
    # Upgrade existing release
    helm upgrade $RELEASE_NAME ./helm/postgres `
        --namespace $NAMESPACE `
        --values ./helm/postgres/$VALUES_FILE `
        --wait `
        --timeout 5m
    
    Write-Success "✓ Helm release upgraded successfully!"
} else {
    Write-Info "Installing new Helm release..."
    Write-Host ""
    
    # Install new release
    helm install $RELEASE_NAME ./helm/postgres `
        --namespace $NAMESPACE `
        --values ./helm/postgres/$VALUES_FILE `
        --wait `
        --timeout 5m
    
    Write-Success "✓ Helm release installed successfully!"
}

Write-Host ""
Write-Success "========================================"
Write-Success "Deployment Complete!"
Write-Success "========================================"
Write-Host ""

# Display status
Write-Info "Helm Release Status:"
helm status $RELEASE_NAME -n $NAMESPACE

Write-Host ""
Write-Info "Kubernetes Resources:"
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
Write-Host "  kubectl logs -f postgres-service-0 -n $NAMESPACE"
Write-Host ""

Write-Info "Connect to database:"
Write-Host "  kubectl exec -it postgres-service-0 -n $NAMESPACE -- psql -U postgres"
Write-Host ""

Write-Info "Port forward to localhost:"
Write-Host "  kubectl port-forward -n $NAMESPACE svc/postgres-service 5432:5432"
Write-Host ""

Write-Info "Helm commands:"
Write-Host "  helm list -n $NAMESPACE"
Write-Host "  helm history $RELEASE_NAME -n $NAMESPACE"
Write-Host "  helm uninstall $RELEASE_NAME -n $NAMESPACE"
Write-Host ""

Write-Success "Deployment successful! ✓"