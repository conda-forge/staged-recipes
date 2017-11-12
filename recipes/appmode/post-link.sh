#!/bin/sh

"${PREFIX}/bin/jupyter" nbextension     enable --py --sys-prefix appmode
"${PREFIX}/bin/jupyter" serverextension enable --py --sys-prefix appmode
