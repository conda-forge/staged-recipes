# aliases for maintaining this conda package

.PHONY: build install convert upload

VERSION=2.9-9
PACKAGE=bash-completion-$(VERSION).tar.bz2

build:
	conda build . --no-anaconda-upload

install:
	conda install -c local --yes --force-reinstall bash-completion

convert:
	conda convert -p all -o ~/anaconda3/conda-bld ~/anaconda3/conda-bld/linux-64/$(PACKAGE)

upload:
	anaconda upload --skip-existing ~/anaconda3/conda-bld/*/$(PACKAGE)
