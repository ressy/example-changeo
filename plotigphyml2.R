# https://changeo.readthedocs.io/en/stable/examples/igphyml.html#visualize-results

library(alakazam)
library(ape)

args <- commandArgs(trailingOnly = TRUE)
db <- readIgphyml(args[1], format="phylo")

# Plot largest lineage tree
pdf(args[2])
plot(ladderize(db$trees[[1]]),cex=0.7,no.margin=TRUE)
dev.off()
