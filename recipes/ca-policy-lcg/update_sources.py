#!/usr/bin/env python3
import gzip
import hashlib
import xml.etree.ElementTree as ET

import requests

base_url = 'https://repository.egi.eu/sw/production/cas/1/current/'
metapackage_name = 'ca-policy-lcg'

# Parse the repo manifest
response = requests.get(base_url+'repodata/repomd.xml')
assert response.ok
root = ET.fromstring(response.content)
for element in list(root):
    if element.attrib.get('type') == 'primary':
        location = element.find('./{http://linux.duke.edu/metadata/repo}location')
        primary_url = base_url+location.attrib['href']

    if element.attrib.get('type') == 'filelists':
        location = element.find('./{http://linux.duke.edu/metadata/repo}location')
        filelists_url = base_url+location.attrib['href']

assert filelists_url and primary_url

# Parse the RPM requirements
response = requests.get(primary_url)
assert response.ok
root = ET.fromstring(gzip.decompress(response.content))
dependency_map = {}
for package in root.findall('{http://linux.duke.edu/metadata/common}package'):
    name = package.find('{http://linux.duke.edu/metadata/common}name').text
    print(name)
    dependencies = package.find('{http://linux.duke.edu/metadata/common}format')
    dependencies = dependencies.find('{http://linux.duke.edu/metadata/rpm}requires')
    if dependencies:
        dependency_map[name] = {d.attrib['name'] for d in dependencies}

to_install = {metapackage_name}
checked = to_install.copy()
while checked:
    dep_name = checked.pop()
    if dep_name in dependency_map:
        to_install = to_install.union(dependency_map[dep_name])
        checked = checked.union(dependency_map[dep_name])

response = requests.get(filelists_url)
assert response.ok

# Compute the tarball hashes
urls = {}
past_version = None
root = ET.fromstring(gzip.decompress(response.content))
for package in root.findall('{http://linux.duke.edu/metadata/filelists}package'):
    name = package.attrib.get('name')
    if package.attrib.get('arch') != 'src':
        # print('Skipping', name)
        continue
    if name not in to_install:
        print('Skipping unrequired tarball', name)
        continue

    version = package.find('{http://linux.duke.edu/metadata/filelists}version')
    version = version.attrib['ver']
    assert past_version is None or version == past_version
    past_version = version

    files = [f.text for f in package.findall('{http://linux.duke.edu/metadata/filelists}file')]
    gz_files = [fn for fn in files if fn.endswith('.tar.gz')]
    assert len(gz_files) == 1, files

    url = base_url+'tgz/'+gz_files[0]
    response = requests.get(url)
    assert response.ok

    file_hash = hashlib.sha256()
    file_hash.update(response.content)
    print('Got hash', file_hash.hexdigest(), 'for', package.attrib.get('name'))
    urls[url.replace(version, '{{ version }}')] = file_hash.hexdigest()

    to_install.remove(name)

# Print the results
print('Version is', version)
for url, file_hash in urls.items():
    print('  - url:', url)
    print('    sha256:', file_hash)
    print('    folder:', metapackage_name)
