
<!-- README.md is generated from README.Rmd. Please edit that file -->

# snowimputr

This package includes convenient functions to identify deleted messages
in Telegram datasets using the consecutive numbering of message IDs when
Telegram data is scraped via the Telethon API. Those IDs are then
queried in the overall dataset to reconstruct the original message
history of the dataset.

## Installation

You can install snowimputr from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("buehlk/snowimputr")
```
