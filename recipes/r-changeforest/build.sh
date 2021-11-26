# from https://github.com/conda-forge/r-randomforest-feedstock
if [[ $target_platform =~ linux.* ]] || [[ $target_platform == win-32 ]] || [[ $target_platform == win-64 ]] || [[ $target_platform == osx-64 ]]; then
  export DISABLE_AUTOBREW=1
  $R CMD INSTALL --build changeforest-r
else
  # TODO: What does this do?
  mkdir -p $PREFIX/lib/R/library/changeforest
  mv * $PREFIX/lib/R/library/changeforest
fi 