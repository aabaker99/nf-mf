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
