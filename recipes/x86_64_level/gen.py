import archspec.cpu

archs = archspec.cpu.TARGETS

x86_64_levels = {}

name_mapping = {
  "x86_64": 1,
  "x86_64_v2": 2,
  "x86_64_v3": 3,
  "x86_64_v4": 4,
}

for arch_name, arch in archs.items():
    if arch.family.name != "x86_64":
        continue
    if arch.parents:
        level = max(name_mapping.get(parent.name, 0) for parent in arch.ancestors)
    else:
        level = 1
    x86_64_levels[arch_name] = level

print("microarchitecture:")
for arch in x86_64_levels.keys():
    print(f"- {arch}")
print()
print("level:")
for level in x86_64_levels.values():
    print(f"- {level}")
