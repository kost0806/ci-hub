# AI Design Documentation Local Server Script (PowerShell)

param(
    [Parameter(Position=0)]
    [string]$Command = "start"
)

$ErrorActionPreference = "Stop"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Show-Banner {
    Write-ColorOutput Cyan "================================================"
    Write-ColorOutput Cyan "   AI Design Docs Local Server (Docker)"
    Write-ColorOutput Cyan "================================================"
}

function Show-Help {
    Show-Banner
    Write-Host ""
    Write-ColorOutput Yellow "Usage:"
    Write-Host "  .\run-docs.ps1 [command]"
    Write-Host ""
    Write-ColorOutput Yellow "Commands:"
    Write-Host "  start     - Start the documentation server (default)"
    Write-Host "  stop      - Stop the documentation server"
    Write-Host "  restart   - Restart the documentation server"
    Write-Host "  logs      - View server logs"
    Write-Host "  build     - Rebuild Docker image"
    Write-Host "  clean     - Remove containers and volumes"
    Write-Host "  status    - Check container status"
    Write-Host "  help      - Show this help message"
    Write-Host ""
    Write-ColorOutput Yellow "Examples:"
    Write-Host "  .\run-docs.ps1            # Start server"
    Write-Host "  .\run-docs.ps1 stop       # Stop server"
    Write-Host "  .\run-docs.ps1 logs       # View logs"
    Write-Host ""
}

function Start-Server {
    Show-Banner
    Write-ColorOutput Green "Starting Docker container..."

    # Check if Docker is installed
    try {
        docker --version | Out-Null
    } catch {
        Write-ColorOutput Red "ERROR: Docker is not installed."
        Write-Host "Please install Docker Desktop: https://www.docker.com/products/docker-desktop"
        exit 1
    }

    # Run Docker Compose
    docker-compose up -d

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-ColorOutput Green "SUCCESS: Server is running!"
        Write-Host ""
        Write-ColorOutput Cyan "View documentation at:"
        Write-ColorOutput Yellow "   http://localhost:4000"
        Write-Host ""
        Write-ColorOutput Cyan "Tips:"
        Write-Host "   - Documents will auto-reload on changes (LiveReload)"
        Write-Host "   - View logs: .\run-docs.ps1 logs"
        Write-Host "   - Stop server: .\run-docs.ps1 stop"
        Write-Host ""
    } else {
        Write-ColorOutput Red "ERROR: Failed to start server"
        exit 1
    }
}

function Stop-Server {
    Show-Banner
    Write-ColorOutput Yellow "Stopping Docker container..."
    docker-compose down

    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput Green "SUCCESS: Server stopped."
    } else {
        Write-ColorOutput Red "ERROR: Failed to stop server"
        exit 1
    }
}

function Restart-Server {
    Show-Banner
    Write-ColorOutput Yellow "Restarting server..."
    docker-compose restart

    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput Green "SUCCESS: Server restarted."
        Write-ColorOutput Yellow "   http://localhost:4000"
    } else {
        Write-ColorOutput Red "ERROR: Failed to restart server"
        exit 1
    }
}

function Show-Logs {
    Show-Banner
    Write-ColorOutput Cyan "Showing logs... (Press Ctrl+C to exit)"
    Write-Host ""
    docker-compose logs -f
}

function Build-Image {
    Show-Banner
    Write-ColorOutput Yellow "Building Docker image..."
    docker-compose build --no-cache

    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput Green "SUCCESS: Image built successfully"
    } else {
        Write-ColorOutput Red "ERROR: Failed to build image"
        exit 1
    }
}

function Clean-All {
    Show-Banner
    Write-ColorOutput Yellow "Cleaning up containers and volumes..."

    # Confirmation
    $confirmation = Read-Host "Remove all containers and volumes? (y/N)"
    if ($confirmation -ne 'y') {
        Write-ColorOutput Yellow "Cancelled."
        return
    }

    docker-compose down -v

    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput Green "SUCCESS: Cleanup complete"
    } else {
        Write-ColorOutput Red "ERROR: Cleanup failed"
        exit 1
    }
}

function Show-Status {
    Show-Banner
    Write-ColorOutput Cyan "Container status:"
    Write-Host ""
    docker-compose ps
}

# Command handling
switch ($Command.ToLower()) {
    "start" { Start-Server }
    "stop" { Stop-Server }
    "restart" { Restart-Server }
    "logs" { Show-Logs }
    "build" { Build-Image }
    "clean" { Clean-All }
    "status" { Show-Status }
    "help" { Show-Help }
    default {
        Write-ColorOutput Red "ERROR: Unknown command: $Command"
        Write-Host ""
        Show-Help
        exit 1
    }
}
