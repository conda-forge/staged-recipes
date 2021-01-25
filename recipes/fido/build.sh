
#Rscript -e "Sys.setenv(TAR = '/bin/tar'); devtools::install_github(\"jsilve24/fido\")"
export TAR=/bin/tar
wget https://github.com/mortonjt/driver/archive/v.0.0.1.tar.gz
R CMD INSTALL --build v.0.0.1.tar.gz
R CMD INSTALL --build .
