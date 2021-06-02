import json
import os
import shutil
import subprocess
import sys
import urllib.parse as urllib_parse
import urllib.request as urllib_request


def url_to_path(url):
    """
    Convert a file: URL to a path.
    """
    assert url.startswith('file:'), (
        "You can only turn file: urls into filenames (not %r)" % url)

    _, netloc, path, _, _ = urllib_parse.urlsplit(url)

    # if we have a UNC path, prepend UNC share notation
    if netloc:
        netloc = '\\\\' + netloc

    path = urllib_request.url2pathname(netloc + path)
    return path


def copy_output_files(build_event_file, bin_dir):
    with open(build_event_file, 'r') as f:
        for line in f.readlines():
            event = json.loads(line) 
            if 'completed' not in event:
                continue
            if 'importantOutput' in event['completed']:
                for output_name in event['completed']['importantOutput']:
                    path = url_to_path(output_name['uri'])
                    outfile_name = os.path.abspath(path)
                    target_name = os.path.join(bin_dir, os.path.basename(outfile_name))
                    shutil.copy2(outfile_name, target_name)
                    

# Setup
PREFIX=os.environ['PREFIX']
os.chdir('pkgs/ncbi-datasets-cli')

BIN_DIR='{}/bin/'.format(PREFIX)
if not os.path.exists(BIN_DIR):
    os.mkdir(BIN_DIR)

# Build executables
subprocess.run('bazel build --build_event_json_file=build_events.json //src:datasets //src:dataformat',
               shell=True, stdout=sys.stdout, stderr=sys.stderr)

# Find and copy executables
copy_output_files('build_events.json', BIN_DIR)

# Cleanup
subprocess.run('bazel clean', shell=True, stdout=sys.stdout, stderr=sys.stderr)
subprocess.run('bazel shutdown', shell=True, stdout=sys.stdout, stderr=sys.stderr)

