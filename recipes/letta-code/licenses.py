"""Pass the installed npm tree and bundled JS to pnpm-licenses' JSON interface."""
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

root, bundled, output = (Path(arg).resolve() for arg in sys.argv[1:])
staging = output.parent / 'license-inputs'
staging.mkdir(exist_ok=True)
dependencies = []
notices = []
supplements = {
    '@alcalzone/ansi-tokenize': 'ANSI-TOKENIZE-LICENSE',
    'yoga-layout': 'YOGA-LICENSE',
    'standardwebhooks': 'STANDARDWEBHOOKS-LICENSE',
    'proxy-agent-negotiate': 'PROXY-AGENTS-LICENSE',
}
for manifest in sorted([*root.rglob('package.json'), *bundled.rglob('package.json')]):
    data = json.loads(manifest.read_text(encoding='utf-8'))
    if not data.get('name') or not data.get('version'):
        continue
    name, version = data['name'], data['version']
    license_path = manifest.parent
    supplemental = supplements.get(name)
    if name.startswith('@aws-sdk/'):
        supplemental = 'AWS-SDK-LICENSE'
    if name.startswith('@earendil-works/pi-'):
        supplemental = 'PI-LICENSE'
    if supplemental:
        # Supply the real upstream text rather than letting pnpm-licenses
        # synthesize copyright attribution from incomplete npm metadata.
        license_path = staging / str(len(dependencies))
        license_path.mkdir(exist_ok=True)
        shutil.copyfile(bundled.parent / 'supplemental-licenses' / supplemental,
                        license_path / 'LICENSE')
    license_id = data.get('license', data.get('licenses', 'UNKNOWN'))
    if isinstance(license_id, list):
        license_id = ' OR '.join(item['type'] for item in license_id)
    if isinstance(license_id, dict):
        license_id = license_id['type']
    dependency = dict(name=name, version=version, path=str(license_path), license=license_id)
    for key in ('author', 'homepage', 'description'):
        value = data.get(key)
        if key == 'author' and isinstance(value, dict):
            value = value.get('name')
        if isinstance(value, str):
            dependency[key] = value
    dependencies.append(dependency)

    # pnpm-licenses reads one top-level license and NOTICE. Preserve additional
    # licenses and nested attribution (e.g. pi-schema's TypeBox notices) too.
    for path in sorted(manifest.parent.rglob('*')):
        relative = path.relative_to(manifest.parent)
        if not path.is_file() or 'node_modules' in relative.parts:
            continue
        if relative.as_posix() == 'LICENSE' and not supplemental:
            continue
        notice_file = path.name.lower().startswith(
            ('license', 'licence', 'copying', 'notice', 'copyright', 'thirdparty', 'third-party'))
        notice_dir = any(part.lower() in ('licenses', 'third_party_notices', 'third-party-notices')
                         for part in relative.parts[:-1])
        readme = path.name.lower().startswith('readme')
        if not (notice_file or notice_dir or readme):
            continue
        content = path.read_text(encoding='utf-8', errors='replace')
        if readme and 'permission is hereby granted' not in content.lower():
            continue
        notices.append(f'\n--- {name} {version}: {relative} ---\n{content}\n')

# Use the conda build dependency on both platforms without invoking .bat/.cmd
# launchers from Python or installing any license tooling into the package.
build = Path(os.environ['BUILD_PREFIX'])
module = (build / 'Library/share/pnpm-licenses/node_modules' if os.name == 'nt'
          else build / 'lib/node_modules') / '@quantco/pnpm-licenses'
bin_entry = json.loads((module / 'package.json').read_text(encoding='utf-8'))['bin']
if isinstance(bin_entry, dict):
    bin_entry = bin_entry['pnpm-licenses']
command = [shutil.which('node'), str(module / bin_entry)]
inputs, resolved = staging / 'dependencies.json', staging / 'resolved.json'
inputs.write_text(json.dumps({'dependencies': dependencies}), encoding='utf-8')
subprocess.run([*command, 'list', '--json-input-file', str(inputs),
                '--output-file', str(resolved)], check=True)
# The CLI can exit successfully while omitting unresolved licenses.
expected = {(dep['name'], dep['version'], dep['path']) for dep in dependencies}
actual = {(dep['name'], dep['version'], dep['path'])
          for dep in json.loads(resolved.read_text(encoding='utf-8'))}
if actual != expected:
    raise RuntimeError(f'pnpm-licenses omitted dependencies: {sorted(expected - actual)}')
subprocess.run([*command, 'generate-disclaimer', '--json-input-file', str(inputs),
                '--output-file', str(output)], check=True)
with output.open('a', encoding='utf-8') as stream:
    stream.write('\nADDITIONAL UPSTREAM LICENSES AND NOTICES\n')
    stream.writelines(notices)
print(f'pnpm-licenses: collected all {len(dependencies)} package records')
