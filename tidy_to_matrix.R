library(argparse)
library(tidyr)

parser = ArgumentParser(description="Transform a tidied dataset ")
parser$add_argument('--input-y-matrix', '-i')
parser$add_argument('--recount-z-matrix', '-z')
parser$add_argument('--multi-plier-repo', '-r')
parser$add_argument('--outfile', '-o')
args = parser$parse_args()

y_tidy = read.table(args$infile, sep=',', header=TRUE)
y_matrix = rv %>% dplyr::select(id, Symbol, zScore) %>% dplyr::spread(Symbol, zScore)
write.table(rv_spread, args$outfile)
