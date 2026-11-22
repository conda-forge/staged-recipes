"""Collect license notices for installed npm dependencies and bundled JS."""
import json
import sys
from pathlib import Path

root, bundled, output = map(Path, sys.argv[1:])
with output.open('w', encoding='utf-8') as stream:
    for manifest in sorted([*root.rglob('package.json'), *bundled.rglob('package.json')]):
        data = json.loads(manifest.read_text(encoding='utf-8'))
        if not data.get('name') or not data.get('version'):
            continue
        stream.write(f"\n{'=' * 72}\n{data['name']} {data['version']}\n")
        stream.write(f"Declared license: {data.get('license', data.get('licenses', 'unspecified'))}\n")
        supplements = {
            '@alcalzone/ansi-tokenize': 'ANSI-TOKENIZE-LICENSE',
            'yoga-layout': 'YOGA-LICENSE',
            'standardwebhooks': 'STANDARDWEBHOOKS-LICENSE',
            'proxy-agent-negotiate': 'PROXY-AGENTS-LICENSE',
        }
        name = data['name']
        supplemental = supplements.get(name)
        if name.startswith('@aws-sdk/'):
            supplemental = 'AWS-SDK-LICENSE'
        if name.startswith('@earendil-works/pi-'):
            supplemental = 'PI-LICENSE'
        if supplemental:
            stream.write(f"Supplemental upstream license: {supplemental}\n")
        for path in sorted(manifest.parent.rglob('*')):
            relative = path.relative_to(manifest.parent)
            if not path.is_file() or 'node_modules' in relative.parts:
                continue
            license_file = path.name.lower().startswith(('license', 'licence', 'copying', 'notice', 'copyright', 'thirdparty', 'third-party'))
            notice_dir = any(part.lower() in ('licenses', 'third_party_notices', 'third-party-notices') for part in relative.parts[:-1])
            readme = path.name.lower().startswith('readme')
            if not (license_file or notice_dir or readme):
                continue
            content = path.read_text(encoding='utf-8', errors='replace')
            # Some packages put their full MIT text only in the README.
            if readme and 'permission is hereby granted' not in content.lower():
                continue
            stream.write(f"\n--- {relative} ---\n{content}\n")
    for path in sorted((bundled.parent / 'supplemental-licenses').iterdir()):
        if path.is_file():
            stream.write(f"\n{'=' * 72}\n{path.name}\n{path.read_text()}\n")
