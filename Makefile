export PATH := $(PWD)/immcantation/scripts:$(PATH)
# Needed for BuildTrees.py
export IGPHYML_PATH=$(CONDA_PREFIX)/share/igphyml/motifs
SHELL=/bin/bash -o pipefail

# keep all intermediate files
# (".SECONDARY with no prerequisites causes all targets to be treated as
# secondary (i.e., no target is removed because it is considered
# intermediate)")
.SECONDARY:

all: HD13M_igblast_db-pass_parse-select_clone-pass_germ-pass.tsv

realclean: clean
	rm -f AIRR_Example.tar.gz
	rm -rf AIRR_Example/ igblast/ imgt/

clean:
	rm -f HD13M_*

### Example Data
# https://changeo.readthedocs.io/en/stable/examples/igblast.html#example-data

# A tarball with the output FASTA and IgBLAST files from the output of the
# pRESTO example.
AIRR_Example.tar.gz:
	curl -O http://clip.med.yale.edu/immcantation/examples/AIRR_Example.tar.gz

# (There are some extra dot files including at the top level so we specify just
# the directory itself.)
AIRR_Example/HD13M.fasta: AIRR_Example.tar.gz
	tar xzvf $^ AIRR_Example
	touch $@

# There are used in a few different places as the original, IMGT-gapped (for V)
# germline reference.  Equivalently they could come from the imgt/ files.
REF_FASTAS = $(addprefix AIRR_Example/IMGT_Human_IGH,$(addsuffix .fasta,V D J))

### Configuring IgBLAST
# https://changeo.readthedocs.io/en/stable/examples/igblast.html#configuring-igblast

igblast/.done:
	# The full download has some old URLs, but we shouldn't need those
	# anymore anyway, with the newer igblast versions.
	# https://bitbucket.org/kleinstein/immcantation/issues/73/
	#fetch_igblastdb.sh -x -o igblast
	# Another approach, since we're already using conda's igblast with its
	# own IGDATA directory
	mkdir -p igblast
	cp -r $(CONDA_PREFIX)/share/igblast/internal_data igblast
	cp -r $(CONDA_PREFIX)/share/igblast/optional_file igblast
	touch $@

# Downloads data from IMGT servers
imgt/.done:
	fetch_imgtdb.sh -o imgt
	touch $@

# Converts IMGT-provided files into a fresh BLAST database
# (Using one human Ig V file as a placeholder make target here)
DB=igblast/database/imgt_human_ig_v.ndb
$(DB): imgt/.done igblast/.done
	imgt2igblast.sh -i imgt -o igblast

### Running IgBLAST
# https://changeo.readthedocs.io/en/stable/examples/igblast.html#running-igblast

# From here on, each Change-O command takes an input file and appends a suffix
# on the output file for whatever it did.  We have a chain of (mostly) TSV
# files going from one step to the next, heading toward a table of annotated
# functional sequences clustered into clonal groups.

# This assumes that the expected directory tree of files relevant for the
# specified organism are present in the igblast directory (or whatever's given
# with -b).
# The output here is a file in either blast's tabular with comments (.fmt7) or
# AIRR's tabular (.tsv) format.
# The fmt7 file should be equivalent to AIRR_Example/HD13M.fmt7 (not quite
# identical because of slightly different decimal values, etc.).
%_igblast.fmt7: AIRR_Example/%.fasta $(DB)
	AssignGenes.py igblast -s $< -b igblast --organism human --loci ig --format blast --outdir .

### Processing the output of IgBLAST
# https://changeo.readthedocs.io/en/stable/examples/igblast.html#processing-the-output-of-igblast

# Looks like the example files come with a copy of the IMGT IGH(VDJ) FASTAs
# that we also downloaded straight from IMGT.  Either should work here I think.
#
# In any case the command complains about a whole bunch of light chain hits,
# and sure enough, there are IGKV and IGLV lines in HD13M_igblast.fmt7.  Why?
# Spurious hits?  Light chain reads mixed in?  Not sure.
#
# --extended adds a bunch of optional columns to the output.
#
# The output file should be roughly equivalent (as for the .fmt7 above) to
# AIRR_Example/HD13M_db-pass.tsv
%_igblast_db-pass.tsv: %_igblast.fmt7 AIRR_Example/%.fasta
	MakeDb.py igblast -i $< -s $(word 2,$^) -r $(REF_FASTAS) --extended

### Filtering records: Removing non-productive sequences
# https://changeo.readthedocs.io/en/1.0.2/examples/filtering.html#filtering-records
# https://changeo.readthedocs.io/en/1.0.2/examples/filtering.html#removing-non-productive-sequences
%_parse-select.tsv: %.tsv
	ParseDb.py select -d $^ -f productive -u T

# "If you have data that includes both heavy and light chains in the same
# library..." do we?  I think not? Skipping the "disagreements between the
# C-region primers and the reference alignment" filter for now

### Clustering sequences into clonal groups
# https://changeo.readthedocs.io/en/1.0.2/examples/cloning.html
#
# Should try this-- do I get the expected dist of 0.16?
# https://shazam.readthedocs.io/en/stable/vignettes/DistToNearest-Vignette/

# The output here has a clone_id column, with each sequence assigned a clone
# ID.  A bunch will be singletons but some larger.
# With --failed included, every line in the input file will end up in either
# the pass.tsv or the fail.tsv file.  It looks to me like it's those with Ns in
# the junction (and thus Xs in the junction_aa) that fail but I'm not totally
# sure.
%_clone-pass.tsv: %.tsv
	DefineClones.py -d $^ --act set --model ham --norm len --dist 0.16 --failed

### Reconstructing germline sequences

# Adding germline sequences to the database
# https://changeo.readthedocs.io/en/latest/examples/germlines.html#adding-germline-sequences-to-the-database

# --cloned because we do have a clone_id column in our input (AIRR) file.
%_germ-pass.tsv: %.tsv
	CreateGermlines.py -d $^ -g dmask --cloned -r $(REF_FASTAS)

# https://changeo.readthedocs.io/en/latest/examples/igphyml.html
# The instructions on this page are for a small IgPhyML-provided example
# dataset.  I'll try to adapt it to the same dataset we're working on already.

# It looks like this can just prepare the input files for IgPhyML, but with
# --igphyml it'll also run automatically.
build_trees: HD13M_igblast_db-pass_parse-select_clone-pass_germ-pass.tsv
	BuildTrees.py -d $^ --collapse --igphyml
