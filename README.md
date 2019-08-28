# nf-mf
Tools for matrix factorization methods for NF.

Files in this repository are associated with applying matrix factorization (MF) methods to a large cancer dataset, recount2.
The methods are thought to learn a useful model or latent representation of the data.
In particular, MF identifies gene signatures/latent vectors, in an unsupervised manner, that characterize differences among the cancer samples.
The MF model is then applied/transferred to another setting: the analysis of Neurofibromatosis (NF).
For each sample, the model provides a loading/score for each latent vector.
The latent variable loadings may be used to differentiate samples of different NF disease status.
We may then inspect the latent variables in the model to understand which genes or groups of genes are responsible for the differentiation.
In doing so, we gain insights into the biology driving the NF disease and its progression.

## scripts/CoGAPS_wrapper.R
This is a command-line interface I wrote to run CoGAPS.
In addition to the shared matrix dimension parameter, `--k-latent`, there is a parameter called `--n-sets` which is important for the distributed version of CoGAPS.
The parameter serves to partition the samples in the input data so that different CoGAPS processes can learn patterns among their assigned samples only, and not among all the samples in the dataset.
The sets are filled with an approximately equal number samples.
`--n-sets` should be set so that there are sufficiently many samples to learn patterns among.
I chose to set this parameter to 30 when running CoGAPS on the recount2 dataset, which resulted in partitions of approximately 1200 samples.
This parameter should be less than or equal to the number of processors available on the machine CoGAPS will run on.

## scripts/recount_rds_to_tsv.R
This script prepares the recount2 data for use in Python (by converting the .RDS file to a .tsv) after some light preprocessing to ENSG identifier version numbers.

## scripts/synapse_add_folder
Convenience script to upload a directory and all its contents to Synapse.

## scripts/transfer_learning.R
A script to follow the Multi-PLIER model of transfer learning.
The Multi-PLIER model is roughly `Y = Z B` where `Y` is a gene x sample measurement matrix from the rare disease of interest, `Z` is a learned gene x latent representation from another dataset (recount2 in this case), and `B` is the matrix to compute.
This corresponds to left-multiplying both sides by the pseudoinverse of `Z`.

## scripts/kolmogorov_smirinov.R
A script to identify which latent variables can distinguish samples of different disease states.

## scripts/cluster.py
A visualization tool for transferred features. Generates PCA plot, computes Adjusted Rand Index to measure agreement of maximum loading (as a clustering procedure) with the clustering reported by sample tumor types, and plots latent variable correlations within and across tumor types.

## scripts/limma.R
Alternative to kolmogorov_smirinov.R to measure "differentially expressed" latent variables. Initial tests reported all latent variables as differentially expressed.

## recount2 data
https://ndownloader.figshare.com/files/10881866

## TODO
- Refine design matrix in limma.R to increase cutoff for differential expression and focus on a smaller set of LVs
