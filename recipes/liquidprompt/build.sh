#!/usr/bin/env bash
set +x

set windows=
if [[ $OS == Windows* ]]; then
    windows=1
    export PATH=${LIBRARY_BIN}:$PATH
fi

# there is no build step

export prefix=$PREFIX
if [ ! -z ${windows} ]; then
   exit 1
else
   sed -e "s|/etc/liquidpromptrc|$PREFIX/etc/liquidpromptrc|g" \
       -i \
       liquidprompt
   sed -e "s|~/.config/liquidprompt/nojhan.theme|$PREFIX/etc/liquidprompt/liquid.theme|" \
       -e "s|~/.config/liquidprompt/nojhan.ps1|$PREFIX/etc/liquidprompt/liquid.ps1|" \
       -i \
       liquidpromptrc-dist

   mkdir -p $PREFIX/etc/conda/activate.d
   cp liquidprompt $PREFIX/etc/conda/activate.d/liquidprompt.sh
   cp liquidpromptrc-dist $PREFIX/etc/liquidpromptrc

   mkdir -p $PREFIX/etc/liquidprompt
   cp liquid.ps1 liquid.theme $PREFIX/etc/liquidprompt
fi
