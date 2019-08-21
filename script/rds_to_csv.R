#!/usr/bin/env Rscript
requireNamespace('argparse')
main = function() {
  parser = argparse::ArgumentParser(description=paste0("",
"Assumes <--infile> is an RDS file which can be the target of write.table",
"",
"TODO",
"----",
"- Type checking",
""))
  parser$add_argument('--infile', '-i', help="rds file")
  parser$add_argument('--outdir', '-o', help="Output directory")
  args = parser$parse_args()

  rv = readRDS(args$infile)
  write.table(rv, file.path(args$outdir, sub('.rds', '.tsv', basename(args$infile), ignore.case=TRUE)), sep='\t', row.names=TRUE, col.names=TRUE)
}

main()
