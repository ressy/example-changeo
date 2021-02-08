# Just some shared settings for the conda environment and make.  Not much to
# see here.

export PATH := $(PWD)/immcantation/scripts:$(PATH)
# Needed for BuildTrees.py
export IGPHYML_PATH=$(CONDA_PREFIX)/share/igphyml/motifs
SHELL=/bin/bash -o pipefail

# keep all intermediate files
# (".SECONDARY with no prerequisites causes all targets to be treated as
# secondary (i.e., no target is removed because it is considered
# intermediate)")
.SECONDARY:
