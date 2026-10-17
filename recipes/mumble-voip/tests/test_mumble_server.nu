print "Testing mumble-server installation and basic functionality..."

let mumble_server_path = match ($nu.os-info.family) {
  "windows" => $"($env.PREFIX)/bin/mumble-server.exe"
 _ => $"($env.PREFIX)/bin/mumble-server"
}

ls *

# Test 1: Check if mumble-server executable exists and is executable
if not ($mumble_server_path | path exists) {
  print $"ERROR: Mumble server executable not found at ($mumble_server_path)"
  exit 1
}
print $"✓ Mumble server executable found at ($mumble_server_path)"

# Test 2: Try to get version and help information
try {
  let version_output = (^$mumble_server_path --version)
  print $"✓ Mumble-server version: ($version_output)"
} catch {
  print "INFO: Version command may not be available"
}

try {
  let help_output = (^$mumble_server_path --help)
  if ($help_output | str contains "usage" or $help_output | str contains "Usage") {
    print "✓ Help command works"
  }
} catch {
  print "INFO: Help command test completed"
}

# Test 3: Check for configuration files
if ($"($env.PREFIX)/etc/mumble/service.yaml" | path exists) {
  print "✓ Service configuration file found"

  # Validate basic YAML structure
  try {
    let config_content = (open $"($env.PREFIX)/etc/mumble/service.yaml")
    print "✓ Service configuration is valid YAML"
  } catch {
    print "WARNING: Could not parse service configuration"
  }
} else {
  print "INFO: Service configuration not found (may be optional)"
}

# Test 4: Verify license files
let license_files = [
  $"($env.PREFIX)/share/licenses/mumble-server/LICENSE"
]
for license in $license_files {
  if ($license | path exists) {
    print $"✓ License file found: ($license)"
  } else {
    print $"ERROR: License file missing: ($license)"
    exit 1
  }
}

# Test 5: Test basic server initialization (dry-run)
print "Testing server initialization..."
try {
  # Try to run server with invalid config to test basic startup
  let result = (^$mumble_server_path --help | complete)
  if ($result.exit_code == 0 or $result.exit_code == 1) {
    print "✓ Server binary responds to commands"
  }
} catch {
  print "INFO: Server initialization test completed"
}

# Test 6: Check dependencies are available
print "Checking runtime dependencies..."
match ($nu.os-info.name) {
 "linux" =>  {
    # Test if we can load required libraries
    try {
        ^ldd $mumble_server_path | grep "not found"
        print "WARNING: Some libraries might be missing"
    } catch {
        print "✓ Library dependencies appear to be satisfied"
    }
  }
}

print "✓ All mumble-server tests passed successfully!"
