#!/bin/bash

wget http://www.hepforge.org/archive/cutlang/cms_opendata_ttbar.root
wget http://www.hepforge.org/archive/cutlang/atla_opendata_had_ttbar.root
wget -O delphes_events_ttbar.root https://docs.google.com/uc?export=download\&id=1P8Pv2hmV4QcMfNWmQTsuAkqIYcEzsuxt

echo "Testing"
echo "Using Bash Scripts"
echo "With CMSOD"
echo "CLA ./cms_opendata_ttbar.root CMSOD -i ./exHistos.adl -e 10000"
CLA ./cms_opendata_ttbar.root CMSOD -i ./exHistos.adl -e 10000
echo "With ATLASOD"
echo "CLA ./atla_opendata_had_ttbar.root ATLASOD -i ./exHistos.adl -e 10000"
CLA ./atla_opendata_had_ttbar.root ATLASOD -i ./exHistos.adl -e 10000
echo "With DELPHES"
echo "CLA ./delphes_events_ttbar.root DELPHES -i ./exHistos.adl -e 10000"
CLA ./delphes_events_ttbar.root DELPHES -i ./exHistos.adl -e 10000
