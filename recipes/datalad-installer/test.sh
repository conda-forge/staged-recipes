#!/bin/bash
case "$(uname)" in
    Darwin)
        # The lengthy default $TMPDIR on macOS causes lengthy shebangs when
        # installing Miniconda.  If the shebang exceeds 127 characters,
        # Miniconda refuses to use it, instead setting the first line of the
        # "conda" script to "#!/usr/bin/env python", which results in a
        # non-working installation.  Hence, we need a shorter $TMPDIR.
        #
        # Related issue: <https://github.com/conda/conda/issues/9360>
        export TMPDIR=/tmp
        ;;
esac

exec python -m pytest -vv --ci -m 'not miniconda' test
