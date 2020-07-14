cat << EOF > ${SRC_DIR}/chemper/_version.py
import json


version_json = '''
{
 "date": "2019-12-12T00:00:00-0000",
 "dirty": false,
 "error": null,
 "full-revisionid": "dab37943b0a0ee063072b07f136839eae0170484",
 "version": "1.0.0"
}
'''  # END VERSION_JSON

def get_versions():
    return json.loads(version_json)
EOF

python -m pip install . -vv
