# Change-O Example

**(Work In Progress)**

These files try to step through the [Change-O] examples that use the
`AIRR_Example` dataset from [Immcantation], mainly:

 1. [Running IgBLAST](https://changeo.readthedocs.io/en/stable/examples/igblast.html)
 2. [Filtering Records](https://changeo.readthedocs.io/en/stable/examples/filtering.html)
 3. [Clustering sequences into clonal groups](https://changeo.readthedocs.io/en/stable/examples/cloning.html)
 4. [Reconstructing germline sequences](https://changeo.readthedocs.io/en/stable/examples/germlines.html)
 5. [IgPhyML lineage tree analysis](https://changeo.readthedocs.io/en/stable/examples/igphyml.html)

I've set this up with [conda] and GNU make so it runs a little differtly than
the Docker approach the AIRR community is standardizing around.  In short:

    conda env update -f environment.yml
    conda activate example-changeo
    make

[Change-O]: https://changeo.readthedocs.io/en/stable/
[Immcantation]: https://immcantation.readthedocs.io/en/stable/
