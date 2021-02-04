export PATH := $(PWD)/immcantation/scripts:$(PATH)
SHELL=/bin/bash -o pipefail
IGBLASTURL = ftp://ftp.ncbi.nih.gov/blast/executables/igblast/release

all: HD13M_igblast.fmt7

realclean:
	rm -f AIRR_Example.tar.gz
	rm -rf AIRR_Example/ igblast/ imgt/

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

### Configuring IgBLAST
# https://changeo.readthedocs.io/en/stable/examples/igblast.html#configuring-igblast

igblast/.done:
	# has some old URLs
	# https://bitbucket.org/kleinstein/immcantation/issues/73/
	#fetch_igblastdb.sh -o igblast
	mkdir -p $(dir $@)
	wget -q -r -nH --cut-dirs=5 --no-parent $(IGBLASTURL)/database -P $(dir $@)database
	wget -q -r -nH --cut-dirs=5 --no-parent $(IGBLASTURL)/old_internal_data -P $(dir $@)/internal_data
	wget -q -r -nH --cut-dirs=5 --no-parent $(IGBLASTURL)/old_optional_file -P $(dir $@)/optional_file
	touch $@

imgt/.done:
	fetch_imgtdb.sh -o imgt
	touch $@

DB=igblast/database/imgt_human_ig_v.ndb
$(DB): imgt/.done igblast/.done
	imgt2igblast.sh -i imgt -o igblast

### Running IgBLAST
# https://changeo.readthedocs.io/en/stable/examples/igblast.html#running-igblast

# This assumes that the expected directory tree of files relevant for the
# specified organism are present in the igblast directory (or whatever's given
# with -b).
# The output here is a file in either blast's tabular (.fmt7) or AIRR's tabular
# (.tsv) format.
HD13M_igblast.fmt7: AIRR_Example/HD13M.fasta $(DB)
	AssignGenes.py igblast -s $< -b igblast --organism human --loci ig --format blast --outdir .

### Processing the output of IgBLAST
# https://changeo.readthedocs.io/en/stable/examples/igblast.html#processing-the-output-of-igblast

proc: HD13M_igblast.fmt7 AIRR_Example/HD13M.fasta
	MakeDb.py igblast -i $< -s $(word 2,$^) -r $(addsuffix .fasta,$(addprefix AIRR_Example/IMGT_Human_IGH,V D J)) --extended
