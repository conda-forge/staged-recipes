CD examples_to_run\SIESTA_chabazite_zeolite_example\DDEC6
COPY ..\chabazite.XSF .
mklink "atomic_densities" "%PREFIX%\share\chargemol\atomic_densities\"

REM Pass directory containing jobcontrol.txt
( echo "%cd%\" ) | chargemol
DIR
CD ..\..\..
