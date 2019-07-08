library(argparse)
library(biomaRt)
library(recount)
library(PLIER)

prep_recount_multiplier = function(rpkm_rds) {
  # https://github.com/greenelab/rheum-plier-data/blob/978c37938383ff7adcadacfcbc35931ce5e62b17/recount2/2-prep_recount_for_plier.R
  # normalized recount2 data
  `%>%` <- dplyr::`%>%`
  rpkm.df <- readRDS(rpkm_rds)

  # set seed for reproducibility
  set.seed(12345)

  # Transform ensembl id to genesymbol
  mart <- biomaRt::useDataset("hsapiens_gene_ensembl", 
                              biomaRt::useMart("ensembl"))
  genes <- unlist(lapply(strsplit(rpkm.df$ENSG, "[.]"), `[[`, 1))
  rpkm.df$ensembl_gene_id <- unlist(lapply(strsplit(rpkm.df$ENSG, "[.]"), 
                                           `[[`, 1))
  gene.df <- biomaRt::getBM(filters = "ensembl_gene_id",
                            attributes = c("ensembl_gene_id", "hgnc_symbol"),
                            values = genes, 
                            mart = mart)
  # filter to remove genes without a gene symbol
  gene.df <- gene.df %>% dplyr::filter(complete.cases(.))
  # add gene symbols to expression df
  rpkm.df <- dplyr::inner_join(gene.df, rpkm.df, 
                               by = "ensembl_gene_id")
  # set symbols as rownames (req'd for PLIER)
  rownames(rpkm.df) <- make.names(rpkm.df$hgnc_symbol, unique = TRUE)
  # remove gene identifier columns
  rpkm.df <- rpkm.df %>% dplyr::select(-c(ensembl_gene_id:ENSG))

  # PLIER prior information (pathways)
  allPaths <- PLIER::combinePaths(bloodCellMarkersIRISDMAP, svmMarkers,
                                  canonicalPathways)
  cm.genes <- PLIER::commonRows(allPaths, rpkm.df)

  # filter to common genes before row normalization to save on computation
  rpkm.cm <- rpkm.df[cm.genes, ]
  return(rpkm.cm)
}

# extract data frame my_df = readRDS(recount_data_prep_PLIER.RDS)
# and save the my_df$rpkm.cm as a separate RDS file for CoGAPS
parser = ArgumentParser()
parser$add_argument('--rpkm', '-r', required=TRUE, help="Raw RPKM values in an RDS")
parser$add_argument('--outdir', '-o', required=TRUE)
args = parser$parse_args()

rpkm.cm = prep_recount_multiplier(args$rpkm)
saveRDS(rpkm.cm, file.path(args$outdir, 'recount2_data_prep_CoGAPS.RDS'))
