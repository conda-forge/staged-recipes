# Install the package
$PYTHON setup.py install --single-version-externally-managed --record=record.txt

# Create auxiliary dirs
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d
mkdir -p $PREFIX/etc/pydm

# Create auxiliary vars
DESIGNER_PLUGIN_PATH=$PREFIX/etc/pydm
DESIGNER_PLUGIN=$DESIGNER_PLUGIN_PATH/pydm_designer_plugin.py
ACTIVATE=$PREFIX/etc/conda/activate.d/pydm.sh
DEACTIVATE=$PREFIX/etc/conda/deactivate.d/pydm.sh

echo "from pydm.widgets.qtplugins import *" >> $DESIGNER_PLUGIN
echo "export PYQTDESIGNERPATH="$DESIGNER_PLUGIN_PATH":\$PYQTDESIGNERPATH" >> $ACTIVATE
echo "unset PYQTDESIGNERPATH" >> $DEACTIVATE

unset DESIGNER_PLUGIN_PATH
unset DESIGNER_PLUGIN
unset ACTIVATE
unset DEACTIVATE

