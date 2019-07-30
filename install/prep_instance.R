#!/usr/bin/env Rscript
local({
  r <- getOption("repos")
  r["CRAN"] <- "http://cran.r-project.org" 
  options(repos=r)
})
install.packages("argparse")
install.packages("BiocManager")
install.packages("dplyr")
requireNamespace("BiocManager")
requireNamespace("devtools")
BiocManager::install("CoGAPS")
BiocManager::install("biomaRt")
BiocManager::install("qvalue")
BiocManager::install("recount")
devtools::install_github("wgmao/PLIER", ref="afb4ccbf761418535c3e47ec6baeb6bcd8ec716a")
