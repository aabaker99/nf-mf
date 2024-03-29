#!/usr/bin/env Rscript
library(argparse)
library(CoGAPS)

main = function() {
  parser = ArgumentParser(description="Run CoGAPS")
  parser$add_argument('-d', '--data', required=TRUE, help="Data matrix with shape n_samples x n_features")
  parser$add_argument('-k', '--k-latent', required=FALSE, type='integer', default=7, help="CoGAPS nPatterns parameter")
  parser$add_argument('-o', '--outdir', required=TRUE, help="Location to write results")
  parser$add_argument('-t', '--transpose-data', required=FALSE, action='store_true', default=FALSE, help="Provide this flag if the data file is n_features x n_samples")
  parser$add_argument('-s', '--n-sets', required=TRUE, type='integer', help="Number of sets to distribute over")
  args = parser$parse_args()

  # Prepare CoGAPS parameters
  params = new("CogapsParams")
  params = setParam(params, "nPatterns", args$k_latent)
  params <- setDistributedParams(params, nSets=args$n_sets)

  # Run CoGAPS
  # this script expects data to be samples x genes
  # CoGAPS requires data to be genes x samples
  # sampleFactors is samples x latent
  # featureLoadings is feature x latent
  # data \approx sampleFactors \cdot featureLoadings
  results = CoGAPS(args$data, params=params, distributed='single-cell', transposeData=!args$transpose_data, outputFrequency=10)
  write.csv(results@sampleFactors, file.path(args$outdir, 'sample_by_latent.csv'))
  write.csv(results@featureLoadings, file.path(args$outdir, 'feature_by_latent.csv'))
  return(results)
}
results = main()
# there is some metadata that could be written, interrogate with save.image() if desired
