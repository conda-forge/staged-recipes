import os

path = os.path.join(os.environ['PREFIX'], 'lib', 'emscripten-' + os.environ['PKG_VERSION'], '.emscripten')
with open(path, 'r') as fi:
    lines = fi.readlines()

out_lines = []
for line in lines:
	if line.startswith("BINARYEN_ROOT"):
		out_lines.append("BINARYEN_ROOT = os.path.expanduser(os.getenv('BINARYEN', '{}')) # directory\n".format(os.environ['PREFIX']))
	elif line.startswith("LLVM_ROOT"):
		out_lines.append("LLVM_ROOT = os.path.expanduser(os.getenv('LLVM', '{}'))\n".format(os.path.join(os.environ['PREFIX'], 'bin')))
	else:
		out_lines.append(line)

print("Writing out .emscripten config file\n")
print(''.join(out_lines) + '\n')

with open(path, 'w') as fo:
    fo.write(''.join(out_lines))