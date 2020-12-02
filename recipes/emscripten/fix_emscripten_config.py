import os

if os.name == 'nt':
	prefix = os.environ['LIBRARY_PREFIX']
else:
	prefix = os.environ['PREFIX']

pkg_version = os.environ['PKG_VERSION']

print("PACKAGE_PREFIX AND VERSION: ", prefix, pkg_version)

path = os.path.join(prefix, 'lib', 'emscripten-' + pkg_version, '.emscripten')

print("Reading path: ", path)

with open(path, 'r') as fi:
    lines = fi.readlines()

out_lines = []
for line in lines:
	if line.startswith("BINARYEN_ROOT"):
		p = prefix.replace('\\', '/')
		out_lines.append("BINARYEN_ROOT = os.path.expanduser(os.getenv('BINARYEN', '{}')) # directory\n".format(p))
	elif line.startswith("LLVM_ROOT"):
		p = os.path.join(prefix, 'bin').replace('\\', '/')
		out_lines.append("LLVM_ROOT = os.path.expanduser(os.getenv('LLVM', '{}'))\n".format(p))
	else:
		out_lines.append(line)

print("Writing out .emscripten config file\n")
print(''.join(out_lines) + '\n')

with open(path, 'w') as fo:
    fo.write(''.join(out_lines))