# nf-mf
Tools for matrix factorization methods for NF.

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

## recount2 data
https://ndownloader.figshare.com/files/10881866
