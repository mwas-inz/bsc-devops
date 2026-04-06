#!/usr/bin/env bash

# Cleanup Thesis Files Script (Bash)
# Usage: ./cleanup-thesis.sh

echo "Cleaning up LaTeX artifacts..."
cd thesis
rm -f *.aux *.bbl *.bcf *.blg *.fdb_latexmk *.fls *.lof *.lot *.out *.run.xml *.toc *.app *.log
cd ..
echo "Cleanup complete."
