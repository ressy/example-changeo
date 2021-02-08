all_igphyml: ex_igphyml-pass.pdf sample1_igphyml-pass.pdf

clean_igphyml:
	rm -f ex_igphyml-pass.tab sample1_igphyml-pass.tab ex_igphyml-pass.pdf sample1_igphyml-pass.pdf
	rm -f ex.log example.tsv

ex_igphyml-pass.tab:
	cp $(CONDA_PREFIX)/share/igphyml/examples/example.tsv .
	BuildTrees.py \
		-d example.tsv \
		--outname ex \
		--log ex.log \
		--collapse \
		--sample 3000 \
		--igphyml --clean all --nproc 1

sample1_igphyml-pass.tab:
	cp $(CONDA_PREFIX)/share/igphyml/examples/sample1_igphyml-pass.tab .

ex_igphyml-pass.pdf: ex_igphyml-pass.tab
	Rscript plotigphyml.R $^ $@

sample1_igphyml-pass.pdf: sample1_igphyml-pass.tab
	Rscript plotigphyml2.R $^ $@
