#!/usr/bin/env bash

# Compile Thesis Script (Bash)
# Usage: ./compile-thesis.sh

echo "Compiling thesis..."
cd thesis
latexmk -lualatex -interaction=nonstopmode main.tex
cd ..
echo "Compilation complete."
