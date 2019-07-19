library(argparse)
library(tidyr)

# for https://www.synapse.org/#!Synapse:syn18137070
parser = ArgumentParser()
parser$add_argument('--infile', '-i')
parser$add_argument('--outfile', '-o')
args = parser$parse_args()

# write sample x gene
y_tidy = read.csv(args$infile)
y_df_t = y_tidy %>% dplyr::select(id, Symbol, zScore) %>% spread(Symbol, zScore)
sample_names = levels(y_df_t$id)
row.names(y_df_t) = sample_names
write.csv(y_df_t, args$outfile)
