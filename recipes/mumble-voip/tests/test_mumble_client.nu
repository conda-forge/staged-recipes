print "Testing mumble client installation and basic functionality..."

let mumble_path = match ($nu.os-info.family) {
  "windows" => $"($env.PREFIX)/bin/mumble.exe"
  _ => $"($env.PREFIX)/bin/mumble"
}

# Test 1: Check if mumble executable exists and is executable
if not ($mumble_path | path exists) {
  print $"ERROR: Mumble executable not found at ($mumble_path)"
  exit 1
}
print $"✓ Mumble executable found at ($mumble_path)"

# Test 2: Try to get version information
try {
  let version_output = (^$mumble_path --version)
  print $"✓ Mumble version: ($version_output)"
} catch {
  print "WARNING: Could not get version info (expected in headless environment)"
}

# Test 3: Check library dependencies exist
match ($nu.os-info.family) {
  "unix" => {
    let lib_paths = [$"($env.PREFIX)/lib/mumble/libmumble.so", $"($env.PREFIX)/lib/mumble/plugins/"]
    for path in $lib_paths {
        if ($path | path exists) {
        print $"✓ Found library at ($path)"
        } else {
        print $"WARNING: Library not found at ($path)"
        }
    }
  }
}

# Test 4: Verify license files
let license_files = [
  $"($env.PREFIX)/share/licenses/mumble-client/LICENSE"
]
for license in $license_files {
  if ($license | path exists) {
    print $"✓ License file found: ($license)"
  } else {
    print $"ERROR: License file missing: ($license)"
    exit 1
  }
}

print "✅ All mumble client tests passed successfully!"
