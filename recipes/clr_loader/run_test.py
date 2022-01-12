import json
import os
import sys
import tempfile

import clr_loader


if sys.platform == 'win32':
    clr_loader.get_netfx()
if sys.platform != 'win32':
    clr_loader.get_mono()
dotnet_runtime = os.getenv('dotnet_runtime')
runtime_config = {
    'runtimeOptions': {
        'tfm': f'netcoreapp{dotnet_runtime}',
        'framework': {
            'name': 'Microsoft.NETCore.App',
            'version': f'{dotnet_runtime}.0',
        },
    },
}
with tempfile.TemporaryDirectory() as tmpdir:
    runtime_config_file = os.path.join(tmpdir, 'runtime_config.json')
    json.dump(runtime_config, open(runtime_config_file, 'w'))
    clr_loader.get_coreclr(runtime_config_file)
