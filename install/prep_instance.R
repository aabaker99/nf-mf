#!/usr/bin/env Rscript
local({
  r <- getOption("repos")
  r["CRAN"] <- "http://cran.r-project.org" 
  options(repos=r)
})
if (!requireNamespace("argparse", quietly = TRUE)) {
  install.packages("argparse")
}
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages('devtools')
}
requireNamespace("BiocManager")
requireNamespace("devtools")

if (!requireNamespace("CoGAPS", quietly = TRUE)) {
  # TODO use repo instead?
  BiocManager::install("CoGAPS")
}
if (!requireNamespace("biomaRt", quietly = TRUE)) {
  BiocManager::install("biomaRt")
}
if (!requireNamespace("qvalue", quietly = TRUE)) {
  BiocManager::install("qvalue")
}
if (!requireNamespace("recount", quietly = TRUE)) {
  BiocManager::install("recount")
}
if (!requireNamespace("PLIER", quietly = TRUE)) {
  devtools::install_github("wgmao/PLIER", ref="afb4ccbf761418535c3e47ec6baeb6bcd8ec716a")
}
