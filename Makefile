include common.mak
include example.mak
include igphyml.mak

all: all_example all_igphyml

realclean: clean
	rm -f AIRR_Example.tar.gz
	rm -rf AIRR_Example/ igblast/ imgt/

clean: clean_example clean_igphyml
