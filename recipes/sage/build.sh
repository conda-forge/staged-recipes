mkdir -p "$PREFIX"/var/lib/sage/installed

# following are missing now
# maxima, sympow, flask_autoindex, flask_oldsessions, flask_silk, jmol, mathjax, sagenb, sagenb_export, sagetex, tachyon, thebe
# patch, pkgconf

for pkg in alabaster appnope arb babel backports_abc backports_shutil_get_terminal_size backports_ssl_match_hostname boost_cropped brial bzip2 cddlib cephes cliquer combinatorial_designs configparser conway_polynomials cvxopt cycler dateutil docutils ecl eclib ecm elliptic_curves entrypoints fflas_ffpack flask flask_babel flask_openid flint flintqs fpylll freetype functools32 gap gc gcc gf2x gfan giac git givaro glpk gmp graphs gsl iconv imagesize iml ipykernel ipython_genutils ipywidgets itsdangerous jsonschema jupyter_client jupyter_core lcalc libfplll libgap libgd libpng linbox lrcalc m4ri m4rie matplotlib mistune mpc mpfi mpfr mpmath nauty nbconvert nbformat ncurses networkx notebook ntl openblas palp pari pari_galdata pari_seadata_small pathpy pillow planarity polytopes_db ppl prompt_toolkit pycrypto pynac pyparsing python_openid pytz pyzmq r ratpoints readline rubiks rw scipy setuptools_scm singledispatch singular snowballstemmer speaklater sphinx sqlite symmetrica sympy terminado tornado twisted vcversioner werkzeug widgetsnbextension zeromq zlib zn_poly zope_interface; do
    touch "$PREFIX"/var/lib/sage/installed/$pkg
done
    
