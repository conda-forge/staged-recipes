#!/bin/bash

mkdir -p "${PREFIX}/opt/cytoscape"
cp -r ./* "${PREFIX}/opt/cytoscape/"
echo '#!/bin/sh' > ${PREFIX}/bin/cytoscape
echo '' >> ${PREFIX}/bin/cytoscape
echo 'exec $(dirname $0)/../opt/cytoscape/cytoscape.sh $@' >> ${PREFIX}/bin/cytoscape
chmod +x ${PREFIX}/bin/cytoscape

