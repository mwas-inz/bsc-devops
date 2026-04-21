# Compile Thesis Script (PowerShell)
# Usage: ./compile-thesis.ps1

Write-Host "Compiling thesis..." -ForegroundColor Cyan
Push-Location thesis
latexmk -lualatex -interaction=nonstopmode main.tex
Pop-Location
Write-Host "Compilation complete." -ForegroundColor Green
