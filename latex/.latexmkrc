#!/usr/bin/env perl

# PDF generation mode: 1 = use dvipdfmx (standard for Japanese LaTeX)
$pdf_mode = 1;

# SyncTeX support for editor synchronization
$synctex = 1;

# LaTeX engine: uplatex with shell-escape for advanced packages
$latex = 'uplatex --shell-escape -interaction=nonstopmode -synctex=1 %O %S';

# DVI to PDF conversion
$dvipdf = 'dvipdfmx %O -o %D %S';

# BibTeX settings
$bibtex = 'upbibtex';
$bibtex_use = 1;

# Index generation for Japanese
$makeindex = 'mendex';

# Continuous compilation mode (don't halt on errors)
$interaction = 'nonstopmode';
$halt_on_error = 0;
$nonstopmode = 1;

# Auto-detect file dependencies
$dependents_list = 1;

# Clean up these generated files
@generated_exts = qw(aux bbl blg idx ilg ind log out toc synctex.gz fdb_latexmk fls);
