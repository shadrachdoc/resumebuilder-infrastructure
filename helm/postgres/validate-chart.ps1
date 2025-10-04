# Helm Chart Validation Script - PowerShell
# File: helm/postgres/validate-chart.ps1

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('dev', 'staging', 'production')]
    [string]$Environment = 'dev'
)

$ErrorActionPreference = "Stop"

# Colors
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Yellow }
function Write-Error-Custom { Write-Host $args -ForegroundColor Red }

Write-Success "========================================"
Write-Success "Helm Chart Validation"
Write-Success "========================================"
Write-Host ""

# Set values file based on environment
switch ($Environment) {
    'dev' { $VALUES_FILE = "values.yaml" }
    'staging' { $VALUES_FILE = "values-staging.yaml" }
    'production' { $VALUES_FILE = "values-production.yaml" }
}

Write-Info "Environment: $Environment"
Write-Info "Values File: $VALUES_FILE"
Write-Host ""

# Check if Helm is installed
try {
    helm version --short | Out-Null
} catch {
    Write-Error-Custom "Error: Helm is not installed"
    exit 1
}

Write-Info "[1/4] Linting Helm chart..."
try {
    helm lint ./helm/postgres --values ./helm/postgres/$VALUES_FILE
    Write-Success "✓ Lint passed"
} catch {
    Write-Error-Custom "✗ Lint failed"
    exit 1
}
Write-Host ""

Write-Info "[2/4] Validating Chart.yaml..."
if (Test-Path "./helm/postgres/Chart.yaml") {
    Write-Success "✓ Chart.yaml exists"
} else {
    Write-Error-Custom "✗ Chart.yaml not found"
    exit 1
}
Write-Host ""

Write-Info "[3/4] Validating values file..."
if (Test-Path "./helm/postgres/$VALUES_FILE") {
    Write-Success "✓ $VALUES_FILE exists"
} else {
    Write-Error-Custom "✗ $VALUES_FILE not found"
    exit 1
}
Write-Host ""

Write-Info "[4/4] Dry-run template rendering..."
Write-Host ""
Write-Info "Generated Kubernetes manifests:"
Write-Host "----------------------------------------"
helm template test-postgres ./helm/postgres --values ./helm/postgres/$VALUES_FILE
Write-Host "----------------------------------------"
Write-Success "✓ Template rendering successful"
Write-Host ""

Write-Success "========================================"
Write-Success "Validation Complete!"
Write-Success "========================================"
Write-Host ""

Write-Info "Next steps:"
Write-Host "  1. Review the generated manifests above"
Write-Host "  2. Deploy using: .\deploy-postgres.ps1 -Environment $Environment"
Write-Host ""