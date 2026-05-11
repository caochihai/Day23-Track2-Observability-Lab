# PowerShell script for Day 23 Observability Lab on Windows
# Usage: .\run_lab.ps1 [task]
# Tasks: setup, up, down, smoke, load, alert, drift, verify

Param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet("setup", "up", "down", "smoke", "load", "alert", "drift", "verify")]
    [string]$Task
)

switch ($Task) {
    "setup" {
        Write-Host "--- Running Setup ---" -ForegroundColor Cyan
        if (-not (Test-Path ".env")) {
            Copy-Item ".env.example" ".env"
            Write-Host "Created .env from .env.example. Please edit it with your SLACK_WEBHOOK_URL." -ForegroundColor Yellow
        }
        Write-Host "Pulling Docker images..."
        docker pull prom/prometheus:latest
        docker pull grafana/grafana:latest
        docker pull grafana/loki:latest
        docker pull jaegertracing/all-in-one:latest
        docker pull otel/opentelemetry-collector-contrib:latest
        docker pull prom/alertmanager:latest
        
        Write-Host "Verifying Docker..."
        python 00-setup/verify-docker.py
    }

    "up" {
        Write-Host "--- Starting Stack ---" -ForegroundColor Cyan
        docker compose up -d
        Write-Host "Stack starting. Wait ~30s then run '.\run_lab.ps1 smoke'" -ForegroundColor Green
    }

    "down" {
        Write-Host "--- Stopping Stack ---" -ForegroundColor Cyan
        docker compose down
    }

    "smoke" {
        Write-Host "--- Checking Health ---" -ForegroundColor Cyan
        $urls = @(
            @{ name="App"; url="http://127.0.0.1:8000/healthz" },
            @{ name="Prometheus"; url="http://127.0.0.1:9090/-/healthy" },
            @{ name="Alertmanager"; url="http://127.0.0.1:9093/-/healthy" },
            @{ name="Grafana"; url="http://127.0.0.1:3000/api/health" },
            @{ name="Loki"; url="http://127.0.0.1:3100/ready" },
            @{ name="Jaeger"; url="http://127.0.0.1:16686/" },
            @{ name="OTel Col"; url="http://127.0.0.1:8888/metrics" }
        )

        foreach ($item in $urls) {
            try {
                $response = Invoke-WebRequest -Uri $item.url -Method Get -TimeoutSec 2 -ErrorAction Stop -UseBasicParsing
                Write-Host ("  {0,-15}: OK" -f $item.name) -ForegroundColor Green
            } catch {
                Write-Host ("  {0,-15}: FAILED" -f $item.name) -ForegroundColor Red
            }
        }
    }

    "load" {
        Write-Host "--- Running Load Test (60s) ---" -ForegroundColor Cyan
        Push-Location 02-prometheus-grafana/load-test
        locust -f locustfile.py --headless -u 10 -r 2 -t 60s --host http://localhost:8000
        Pop-Location
    }

    "alert" {
        Write-Host "--- Triggering Alert ---" -ForegroundColor Cyan
        Write-Host "Step 1: Stopping app container..."
        docker stop day23-app
        Write-Host "Step 2: Wait 60-90s for Slack notification..." -ForegroundColor Yellow
        Start-Sleep -Seconds 60
        Write-Host "Step 3: Restarting app..."
        docker start day23-app
        Write-Host "Alert should resolve soon." -ForegroundColor Green
    }

    "drift" {
        Write-Host "--- Running Drift Detection ---" -ForegroundColor Cyan
        Push-Location 04-drift-detection
        python scripts/drift_detect.py
        Pop-Location
    }

    "verify" {
        Write-Host "--- Running Rubric Verification ---" -ForegroundColor Cyan
        python scripts/verify.py
    }
}
