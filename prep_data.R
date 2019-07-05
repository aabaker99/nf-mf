library(argparse)

# extract data frame my_df = readRDS(recount_data_prep_PLIER.RDS)
# and save the my_df$rpkm.cm as a separate RDS file for CoGAPS
parser = ArgumentParser()
parser$add_argument('--infile', '-i', required=TRUE)
parser$add_argument('--outfile', '-o', required=TRUE)
args = parser$parse_args()

rv = readRDS(args$infile)
saveRDS(rv$rpkm.cm, args$outfile)
