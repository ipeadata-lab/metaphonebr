
<!-- README.md is generated from README.Rmd. Please edit that file -->

# metaphonebr

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/ipeadata-lab/metaphonebr/graph/badge.svg)](https://app.codecov.io/gh/ipeadata-lab/metaphonebr)
[![R-CMD-check](https://github.com/ipeadata-lab/metaphonebr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ipeadata-lab/metaphonebr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of metaphonebr is to simplify brazilian names phonetically
using a custom metaphoneBR algorithm that preserves ending vowels,
created for aiding in dataset pairing in the absence of unambiguous
keys.

## Installation

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

## Nota <a href="https://www.ipea.gov.br"><img src="man/figures/ipea_logo.png" alt="Ipea" align="right" width="300"/></a>

**metaphonebr** is developed by a team of researchers at Instituto de
Pesquisa Econômica Aplicada (Ipea).
