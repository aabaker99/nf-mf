library(argparse)
library(tidyr)

parser = ArgumentParser(description="Apply MultiPLIER-style transfer learning")
parser$add_argument('--gene-by-sample-tidy', '-y', help='Data for Y in the form of a tidy dataset', required=TRUE)
parser$add_argument('--gene-by-latent', '-z', help='A learned gene-by-latent matrix from a prior run of a matrix factorization method e.g. PRMF, CoGAPS, PLIER, etc.', required=TRUE)
parser$add_argument('--outdir', '-o', help='Directory to write results to', required=TRUE)
args = parser$parse_args()

# PLIER: Y = ZB
# Y is gene x sample
# Z is gene x latent
# B is latent x sample
y_tidy = read.csv(args$gene_by_sample_tidy)
y_df_t = y_tidy %>% dplyr::select(id, Symbol, zScore) %>% spread(Symbol, zScore)
sample_names = levels(y_df_t$id)
row.names(y_df_t) = sample_names

# TODO how to do this step better? mainly the unique
sample_meta = unique(y_tidy %>% dplyr::select(id, tumorType))
write.csv(sample_meta, file.path(args$outdir, 'sample_meta.csv'), row.names=FALSE)

# Z has row names
z_matrix = read.csv(args$gene_by_latent)
z_row_names = levels(z_matrix[,1])
z_matrix = data.matrix(z_matrix[,-1])
row.names(z_matrix) = z_row_names

# Only select genes that the transfer learning model was trained on
common_genes = intersect(row.names(z_matrix), colnames(y_df_t))
y_df_t_select = y_df_t %>% dplyr::select(common_genes)
y_matrix = t(data.matrix(y_df_t_select))
y_matrix[is.na(y_matrix)] = 0

# L2 defaults to smallest singular value in SVD according to PLIER.
# it's probably the case that this parameter does not affect differential expression analysis using B.
# however, this is a poor default (especially in low sample settings): the smallest singular 
# value will most likely be a small value and make the L2 regularizer irrelevant.
# it is a tradeoff between the reconstruction error and the magnitude of values in B.
# these quantities are proportional to the size of Y and B respectively (by virtue of the Frobenius norm).
# therefore, the L2 parameter should also be on that scale to be appreciable.
# for example, the smallest singular value from the recount2 data is 1.6, and in some experiments the
# effect of the L2 parameter is negligible at least up to a setting of 1100 (the ratio of the number 
# of entries in Y to the number of entries in B): the change in the Frobenius norm of B is 
# less than a half a percent. Settings should be a multiplicative factor of this ratio to take effect.
# A 2% decrease in the norm of B was observed with a factor of 10, while a 17% decrease was observed with
# a factor of 100.
m_genes = dim(y_matrix)[1]
n_samples = dim(y_matrix)[2]
k_latent = dim(z_matrix)[2]
ratio = (m_genes * n_samples) / (k_latent * n_samples)
L2 = ratio * 100

# Apply PLIER model to solve for B
# https://github.com/wgmao/PLIER/blob/a2d4a2aa343f9ed4b9b945c04326bebd31533d4d/R/Allfuncs.R#L465
# B = (Z^T Z + \lambda * I)^{-1} * Z^T Y
# this is the formula for a pseudoinverse of Z applied to Y but where there is a L2 regularizer on B
b_matrix = solve(t(z_matrix)%*%z_matrix+L2*diag(k_latent))%*%t(z_matrix)%*%y_matrix
colnames(b_matrix) = sample_names
write.csv(t(b_matrix), file.path(args$outdir, 'sample_by_latent_transfer.csv'))
