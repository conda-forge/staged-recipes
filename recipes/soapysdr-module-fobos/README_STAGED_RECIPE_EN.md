# Conda-forge style split recipe draft

This directory is an experimental conda-forge style polish layer placed next to the already validated monolithic recipe in `packaging/conda`.

Do not delete or replace `packaging/conda` yet. That recipe is the proven Windows/Radioconda baseline. This split recipe is meant to validate a cleaner package architecture before any public feedstock or staged-recipes work.

## Package outputs

The recipe builds the same source tree once and splits the installed files into these outputs:

- `libfobos-regular` — Regular/classic Fobos runtime, import library, header, pkg-config file, and native CLI utilities.
- `libfobos-sdr-agile` — Agile Fobos runtime, import library, header, pkg-config file, and native CLI utilities.
- `soapysdr-module-fobos` — the minimal SoapySDR runtime module and package metadata.
- `rigexpert-fobos-gnuradio-assets` — GRC block YAML files, GRC example flowgraphs, and documentation.
- `rigexpert-fobos-tools` — Python diagnostics and the Fobos Pro Console / WFM receiver demo.

## Local validation commands

Run from an activated Radioconda environment:

```cmd
cd /d C:\dev\SoapyFobosSDR-Radioconda

git checkout main
git pull origin main
git checkout -b conda-forge-style-polish

conda build packaging\conda-forge -c conda-forge
```

Then install all local outputs into a clean Radioconda environment:

```cmd
conda install -y --use-local ^
  libfobos-regular ^
  libfobos-sdr-agile ^
  soapysdr-module-fobos ^
  rigexpert-fobos-gnuradio-assets ^
  rigexpert-fobos-tools
```

Hardware smoke test:

```cmd
SoapySDRUtil --info
SoapySDRUtil --find="driver=fobos"
SoapySDRUtil --probe="driver=fobos,backend=auto"
python "%CONDA_PREFIX%\Library\share\SoapyFobosSDR\tools\fobos_soapy_smoketest.py" --backend auto --freq 100e6 --rate 8e6 --lna 0 --vga 10
```

## Before real conda-forge submission

This draft intentionally uses `source: path: ../..` so it can be tested directly from the current repository branch. A real conda-forge/staged-recipes submission must replace that with a downloadable tagged source archive and `sha256` hash.

Recommended final source form:

```yaml
source:
  url: https://github.com/UR4MCB/SoapyFobosSDR-Radioconda/archive/refs/tags/v1.4.6.tar.gz
  sha256: <release-tarball-sha256>
```

Also re-check licensing text before submission. The top-level package metadata currently says `LGPL-2.1-or-later`, while the bundled Regular/Agile CMake headers mention GPL wording. The actual upstream license files should be reviewed and made unambiguous before public channel submission.
