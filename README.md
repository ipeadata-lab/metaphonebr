
<!-- README.md is generated from README.Rmd. Please edit that file -->

# metaphonebr

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/metaphonebr)](https://CRAN.R-project.org/package=metaphonebr)
[![Codecov test
coverage](https://codecov.io/gh/ipeadata-lab/metaphonebr/graph/badge.svg)](https://app.codecov.io/gh/ipeadata-lab/metaphonebr)
[![check](https://github.com/ipeadata-lab/metaphonebr/actions/workflows/check.yaml/badge.svg)](https://github.com/ipeadata-lab/metaphonebr/actions/workflows/check.yaml)
[![CRAN/METACRAN Total
downloads](https://cranlogs.r-pkg.org/badges/grand-total/metaphonebr?color=blue)](https://CRAN.R-project.org/package=metaphonebr)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of metaphonebr is to simplify brazilian names phonetically
using a custom metaphoneBR algorithm that preserves ending vowels,
created for aiding in dataset pairing in the absence of unambiguous
keys.

## Installation

The package is in the process of submission to CRAN. When it is
accepted, the stable version can be installed with:

``` r
install.packages("metaphonebr")
```

You can install the development version of metaphonebr from
[GitHub](https://github.com/) with :

``` r
# install.packages("remotes")
remotes::install_github("ipeadata-lab/metaphonebr")
```

## Example

This is a basic example which shows how to use the main function:

``` r
example_names <- c("João da Silva", "Maria", "Marya",
                    "Helena", "Elena", "Philippe", "Filipe", "Xavier", "Chavier")
phonetic_codes <- metaphonebr::metaphonebr(example_names)
print(data.frame(original = example_names, metaphonebr = phonetic_codes))
```

### The `metaphoneBR` phonetic encoding algorithm proceeds as follows:

1.  **Initial Cleanup & Preparation:**
    - Remove all diacritics (e.g., “João” becomes “Joao”).
    - Convert the entire string to uppercase (e.g., “Joao” becomes
      “JOAO”).
    - Remove all characters that are not uppercase letters (A-Z) or
      spaces.
    - Ensure single spaces between words and trim leading/trailing
      whitespace.
2.  **Silent Letter Removal:**
    - Remove a silent ‘H’ if it appears at the beginning of any word
      (e.g., “Helena” becomes “Elena”).
3.  **Digraph Simplification (Sound Grouping):**
    - `LH` is replaced by `1` (representing a palatal lateral
      approximant, like in “Filha” -\> “FI1A”).
    - `NH` is replaced by `3` (representing a palatal nasal, like in
      “Manhã” -\> “MA3A”).
    - `CH` is replaced by `X` (representing the /ʃ/ sound, like in
      “Chico” -\> “XICO”).
    - `SH` is replaced by `X` (for foreign names with /ʃ/ sound, like in
      “Shirley” -\> “XIRLEY”).
    - `SCH` is replaced by `X` (approximating /ʃ/ or /sk/, like in
      “Schmidt” -\> “XMIT”).
    - `PH` is replaced by `F` (like in “Philip” -\> “FILIP”).
    - `SC` followed by `E` or `I` becomes `S` (like in “SCENA” -\>
      “SENA”).
    - `SC` followed by `A`, `O`, or `U` becomes `SK` (like in “ESCOVA”
      -\> “ESKOVA”).
    - `QU` or `QÜ` followed by `E` or `I` becomes `K` (e.g., “QUEIJO”
      -\> “KEIJO”).
    - `GU` or `GÜ` followed by `E` or `I` becomes `G` (the `U` is
      silent, e.g., “GUERRA” -\> “GERRA”).
    - Any remaining `QU` becomes `K` (e.g., “QUANTO” -\> “KANTO”).
4.  **Similar Consonant Simplification:**
    - `Ç` is replaced by `S`.
    - `C` followed by `E` or `I` is replaced by `S` (like in “CELSO” -\>
      “SELSO”).
    - Any other `C` (not part of an already transformed digraph like CH
      or SC) is replaced by `K` (like in “CARLOS” -\> “KARLOS”).
    - `G` followed by `E` or `I` is replaced by `J` (like in “GELO” -\>
      “JELO”; GUE/GUI already handled).
    - Any remaining `Q` (that wasn’t part of QU) is replaced by `K`.
    - `W` is replaced by `V` (common Brazilian Portuguese pronunciation,
      e.g., “WALTER” -\> “VALTER”).
    - `Y` is replaced by `I` (e.g., “YARA” -\> “IARA”).
    - `Z` is replaced by `S` (e.g., “ZEBRA” -\> “SEBRA”).
    - `X` preceded by `S` has the `X` removed (e.g., “EXCELENTE” -\>
      “ESELENTE”, to avoid a double /s/ representation from `SKS`).
5.  **Terminal Nasal Sound Simplification:**
    - A word-final `N` is replaced by `M` (e.g., “JOAQUIN” -\>
      “JOAQUIM”).
    - A word-final `AO` is replaced by `OM` (e.g., “JOÃO” -\> “JOOM”).
    - A word-final `ÃES` is replaced by `AES` (e.g., “MÃES” -\> “MAES”).
6.  **Duplicate Vowel Removal:**
    - Sequences of identical adjacent vowels are reduced to a single
      vowel (e.g., “AARAO” -\> “ARAO”).
7.  **Final Cleanup (Duplicate Letters & Spaces):**
    - Sequences of identical adjacent letters (except if they are part
      of the special codes `1` for LH or `3` for NH) are reduced to a
      single letter (e.g., “CARRO” might become “CARO”, “LESSA” becomes
      “LESA”. Note: This rule simplifies sounds like ‘RR’ and ‘SS’ to
      their single counterparts, which is a common Metaphone-style
      simplification).
    - Ensure single spaces between any remaining words and trim
      leading/trailing whitespace again.

The resulting code is an attempt to represent the phonetic signature of
the name in a simplified, standardized way for a Brazilian Portuguese
context. In particular, by construction it preserves ending vowels since
they imply generally gender information in Brazilian Names (ex.: ADRIANO
and ADRIANA).

## Nota <a href="https://www.ipea.gov.br"><img src="man/figures/ipea_logo.png" alt="Ipea" align="right" width="300"/></a>

**metaphonebr** is developed by a team of researchers at Instituto de
Pesquisa Econômica Aplicada (Ipea).
