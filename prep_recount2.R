#!/usr/bin/env Rscript

# convert RDS to csv
rv = readRDS('recount_data_prep_PLIER.RDS')
write.csv(t(rv$rpkm.cm), 'recount2_sample_by_gene.csv') # gene x sample to sample x gene
