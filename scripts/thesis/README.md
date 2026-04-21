# Thesis Scripts

This folder contains scripts for managing the LaTeX thesis document.

## Prerequisites

To compile the thesis locally, you need a LaTeX distribution and Perl (for `latexmk`).

### MiKTeX (LaTeX Distribution)

MiKTeX is a modern C/C++ implementation of TeX and related programs for Windows.

- **Download:** [miktex.org/download](https://miktex.org/download)
- **Installation:** Follow the installer instructions. It is recommended to set "Install missing packages on-the-fly" to "Yes".

### Strawberry Perl

Strawberry Perl is a perl environment for Microsoft Windows that contains all you need to run and develop perl applications. It is required by `latexmk`.

- **Download:** [strawberryperl.com](https://strawberryperl.com/)
- **Installation:** Use the MSI installer.

## Available Scripts

- `compile-thesis.sh` / `compile-thesis.ps1`: Compiles the LaTeX document using `latexmk`.
- `cleanup-thesis.sh` / `cleanup-thesis.ps1`: Removes auxiliary files generated during compilation.
