# Linux

All the R libraries are installed into lib/R, requiring the use of custom
rpaths to be set with patchelf. This is set in the meta.yaml.

R, and several of its dependencies, try to install things into lib64 on 64-bit
Linux, which doesn't work with conda. A way to avoid it is to create a symlink
from lib64/ to lib/ at the beginning of the build and remove it at the end.

# Windows

http://cran.r-project.org/doc/manuals/r-release/R-admin.html#Installing-R-under-Windows
and http://cran.r-project.org/bin/windows/base/rw-FAQ.html (especially the
first one) are your guides.

R uses mingw, not Visual Studio. Download and install the R tools
http://cran.r-project.org/bin/windows/Rtools/. You *must* use these, not some
other mingw install. R_HOME has to be set during the build to the location of
the R installation (C:\R or C:\R64 by default). It's also a good idea to let
the Rtools installer put the tools on the PATH. Be sure to use a normal
cmd shell. The git shell includes its own sh on the PATH, which won't be able
to find the R tools.

Setting `TMPDIR` is important, as the default isn't very useful on Windows
(`/tmp`). It's apparently relative, so I just used `.`, which uses the source
directory.

To build the docs, you will need qpdf
http://sourceforge.net/projects/qpdf/ and MiKTeX http://www.miktex.org/. Let
MiKTeX install packages on the fly. You might have to install some things
manually using `mpm` (MiKTeX Package Manager).

`make distribution` will make *everything*, down to an R installer. I had to
`cp doc\html\logo.jpg %TMPDIR%` (actually `C:\tmp` because it was ignoring
`TMPDIR`).

You need to grab libjpeg, libpng, and libtiff as described at http://cran.r-project.org/doc/manuals/r-release/R-admin.html#Getting-the-source-files.

I had to `cp library\graphics\help\figures\pch.pdf doc\manual\`, `cp
library\graphics\help\figures\mai.pdf doc\manual\`, and `cp
library\graphics\help\figures\oma.pdf doc\manual\` for the docs to build
correctly.

`make distribution` requires the Inno setup installer from
http://jrsoftware.org/.  Make sure you get the Unicode one. Install it to
`C:\packages\Inno` (otherwise you will have to edit the Makefile).

Once you have run `make distribution`, run `cd installer; make imagedir`. This
will put all the files that should be installed into `R-3.2.2` (in the
`installer` directory).  This is what you should "install".


For 64-bit Windows, you need to copy things from C:\R64 instead of C:\R. If
you try to compile as-is, it will fail. The R docs are a little light on
this. They indicate that they use mingw-w64, leading you to download and
install it from SourceForge. You may also think that you need to edit some of
the source code that comes with R to fix some compiler errors. DON'T DO
THIS. IT'S A TRAP. Only use the compilers that come with Rtools.

What you need to do is edit the MkRules.dist in src\gnuwin32 and copy it to
MkRules.local. I had to set `WIN = 64`, `MULTI = 64` and clear `BINDIR64` (it
references an executable name that doesn't seem to exist).

# OS X

The OS X sections of
http://cran.r-project.org/doc/manuals/r-release/R-admin.html are helpful
here. Make sure to set CLFAGS, etc., or else the R configure script will try
to pick up Fink or Homebrew or whatever.

Adding

    CC=clang
    CXX=clang++
    F77=gfortran-4.8
    FC=$F77
    OBJC=clang

to the `config.site` file (according to that page) is a good idea. It seems to
work.

The `--with-blas="-framework Accelerate" --with-lapack` flags to `configure`
enable the Accelerate framework. The `--with-lapack` flag may cause issues.
