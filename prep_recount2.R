#!/usr/bin/env Rscript

# convert RDS to csv
rv = readRDS(file.path('recount2_PLIER_data', 'recount_rpkm.RDS'))
write.csv(t(rv), file.path('recount2_PLIER_data', 'recount2_sample_by_gene.csv'), row.names=FALSE)
