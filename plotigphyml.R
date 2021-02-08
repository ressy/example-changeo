# https://changeo.readthedocs.io/en/stable/examples/igphyml.html#visualize-results

library(alakazam)
library(igraph)

args <- commandArgs(trailingOnly = TRUE)
db <- readIgphyml(args[1])

# Plot largest lineage tree
pdf(args[2])
plot(db$trees[[1]],layout=layout_as_tree)
dev.off()

# Show HLP10 parameters
print(t(db$param[1,]))
