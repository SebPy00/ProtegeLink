$ErrorActionPreference = 'Stop'

$backendPath = Join-Path $PSScriptRoot '..\backend'
Set-Location $backendPath

if (-not (Test-Path '.venv')) {
    python -m venv .venv
}

& .\.venv\Scripts\python.exe -m pip install -e '.[dev]'
& .\.venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

