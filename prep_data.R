library(argparse)
library(biomaRt)

# extract data frame my_df = readRDS(recount_data_prep_PLIER.RDS)
# and save the my_df$rpkm.cm as a separate RDS file for CoGAPS
parser = ArgumentParser()
parser$add_argument('--plier', '-p', required=TRUE, help="Pre-processed RPKM data along with other PLIER parameters as an RDS")
parser$add_argument('--rpkm', '-r', required=TRUE, help="Raw RPKM values in an RDS")
parser$add_argument('--outdir', '-o', required=TRUE)
args = parser$parse_args()

# load MultiPLIER rows
plier_data = readRDS(args$infile)
rows_hgnc = row.names(plier_data$rpkm.cm)
rm(plier_data)

# raw rpkm data has row names in first column
rpkm = readRDS(args$rpkm)
row.names(rpkm) = rpkm[,1]
rpkm = rpkm[,-1]

# map ENSG in recount2 to HGNC
ensembl = useMart("ensembl",dataset="hsapiens_gene_ensembl")
bm_rv = getBM(
  attributes = c("ensembl_gene_id_version", "hgnc_symbol")
  filters = c("ensembl_gene_id_version"),
  values = row.names(rpkm),
  mart = ensembl
)

# use biomaRt mapping to select rows used by MultiPLIER
rows_df = data.frame(ensembl_gene_id_version = row.names(rpkm))
rows_merged = merge(x = rows_df, y = bm_rv, all.x = TRUE, by.x = 'ensembl_gene_id_version', by.y = 'ensembl_gene_id_version')
rows_filtered = rows_merged[rows_merged$hgnc_symbol %in% rows_hgnc,]
saveRDS(rows_filtered, file.path(args$outdir), 'recount2_row_filter.RDS')

# rows are named by ENSG_id
# filter and save
saveRDS(rpkm[rows_filtered$ensembl_gene_id_version,], file.path(args$outdir), 'recount2_data_prep_CoGAPS.RDS')
