I'm preparing a software for publication and I used genomicranges and Iranges for interval operations.  
However, trying to create bioconda recipe using grayskull suggests the BiocPy libraries are not available from conda (bioconda or conda-forge):

```
Could not solve for environment specs
The following packages are incompatible
├─ genomicranges >=0.6.3,<0.7 does not exist (perhaps a typo or a missing channel);
├─ iranges >=0.4.2,<0.5 does not exist (perhaps a typo or a missing channel);
```

This can be resolved by having biocutils, biocframe, genomicranges and iranges on conda-forge - which I am sure could help others too.   
As these packages have little dependency overhead, and are all available from pypi, recipes for them could be generated using [grayskull](https://github.com/conda/grayskull) or [pixi](https://github.com/conda-forge/staged-recipes?tab=readme-ov-file#generating-recipes-with-grayskull): 
```
git clone git@github.com:conda-forge/staged-recipes.git
cd staged-recipes
git remote add upstream https://github.com/BiocPy/staged-recipes.git
git checkout -b add-biocpy

pixi run pypi genomicranges --recursive
pixi run lint
git add recipes/
git commit -m "Add recipe for genomicranges, iranges, biocutils, biocframe and ncls"
git push origin add-biocpy
```
The linting step is suggested soem edits (adding home url for ncls, and adding {{ stdlib('c') }} for ncls and iranges). 
I've ran the above (but with my github username instead of BiocPy) - https://github.com/UriNeri/staged-recipes/tree/add-biocpy - and I can a pull request to conda-forge [staged-recipes](https://github.com/conda-forge/staged-recipes) if it is ok with you. I'd prefer to have BiocPy as the maintainer listed in the meta.yaml files, instead of my username as the default (or we could add both).  
Let me know what you think.
