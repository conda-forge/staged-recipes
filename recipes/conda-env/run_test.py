import json
import os

json_path = os.path.join(os.environ['CONDA_PREFIX'], 'conda-meta',
                         'conda-env-2.6.0-0.json')
with open(json_path) as f:
    json_data=json.loads(f.read())

assert len(json_data['files']) == 0
