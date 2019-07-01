import os
import sys

from nbconvert import nbconvertapp
from notebook.config_manager import BaseJSONConfigManager
from jupyter_core.paths import jupyter_config_path


# Check if bundler extension is enabled
bundler_enabled = False
config_dirs = [os.path.join(p, 'nbconfig') for p in jupyter_config_path()]
for config_dir in config_dirs:
    cm = BaseJSONConfigManager(config_dir=config_dir)
    data = cm.get('notebook')
    if 'bundlerextensions' in data:
        for bundler_id, info in data['bundlerextensions'].items():
            label = info.get('label')
            module = info.get('module_name')
            if module == 'jupyter_docx_bundler':
                bundler_enabled = True
if not bundler_enabled:
    sys.exit('jupyter-dox-bundler not enabled.')


# Check if nbconvert lists docx as available format
formats = nbconvertapp.get_export_names()
if 'docx' not in formats:
    sys.exit('*.docx not in nbconvert export-names.')
