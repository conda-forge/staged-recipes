#!/bin/bash
# We redirect stderr & stdout to conda's .messages.txt; for details, see
#     http://conda.pydata.org/docs/building/build-scripts.html
{
  cmd="\"${PREFIX}/bin/spacy\" link ${PKG_NAME/spacy-model-/} ${PKG_NAME/spacy-model-/}"
  if [ -x \"${PREFIX}/bin/spacy\" ]; then 
    $cmd
  else
    echo "You can link this model to spacy by running:"
    echo "  ${cmd}"
  fi
} >>"${PREFIX}/.messages.txt" 2>&1
