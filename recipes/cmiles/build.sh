cat << EOF > ${SRC_DIR}/cmiles/_version.py
import json


version_json = '''
{
 "date": "2019-05-27T00:00:00-0000",
 "dirty": false,
 "error": null,
 "full-revisionid": "b41a8d8f188a988918cd2ee34c4dbdc44a18b0f5",
 "version": "0.1.5"
}
'''  # END VERSION_JSON

def get_versions():
    return json.loads(version_json)
EOF

python -m pip install . -vv
