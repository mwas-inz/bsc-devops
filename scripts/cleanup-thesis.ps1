# Cleanup Thesis Files Script (PowerShell)
# Usage: ./cleanup-thesis.ps1

Write-Host "Cleaning up LaTeX artifacts..." -ForegroundColor Yellow
Push-Location thesis
Get-ChildItem -Include *.aux, *.bbl, *.bcf, *.blg, *.fdb_latexmk, *.fls, *.lof, *.lot, *.out, *.run.xml, *.toc, *.app, *.log -Recurse | Remove-Item -Force
Pop-Location
Write-Host "Cleanup complete." -ForegroundColor Green
