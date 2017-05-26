curl -o oommf.zip  "http://math.nist.gov/oommf/dist/oommf12b0_20160930_86_x64.zip"

mkdir %PREFIX%\opt

7za x -o%PREFIX%\opt oommf.zip
