#!/usr/bin/env nu

# Cross-platform Nushell build script for OpenShift installer
# Based on https://github.com/openshift/installer/blob/main/hack/build.sh
# Includes cluster-api build functionality from hack/build-cluster-api.sh
# Handles all platform-specific setup and build logic

# Sync envtest binaries
def sync_envtest [cluster_api_bin_dir: string] {
    let envtest_k8s_version = "1.32.0"
    let goos = (run-external "go" "env" "GOOS" | str trim)
    let goarch = (run-external "go" "env" "GOARCH" | str trim)
    let gohostos = (run-external "go" "env" "GOHOSTOS" | str trim)
    let gohostarch = (run-external "go" "env" "GOHOSTARCH" | str trim)
    let envtest_arch = $"($goos)-($goarch)"

    print $"Envtest arch: ($envtest_arch)"
    print $"K8s version: ($envtest_k8s_version)"

    # Check if kube-apiserver already exists and get its version
    let kube_apiserver_exe = if ($nu.os-info.name == "windows") {
        ($cluster_api_bin_dir | path join "kube-apiserver.exe")
    } else {
        ($cluster_api_bin_dir | path join "kube-apiserver")
    }

    if ($kube_apiserver_exe | path exists) {
        # Check for cross-compilation
        if $goos != $gohostos or $goarch != $gohostarch {
            print "Found cross-compiled artifact: skipping envtest binaries version check"
            return
        }

        # Get current version
        let result = do { run-external $kube_apiserver_exe "--version" } | complete
        let current_version = if $result.exit_code == 0 {
            ($result.stdout | str trim | str replace "Kubernetes " "")
        } else {
            "v0.0.0"
        }

        print $"Found envtest binaries with version: ($current_version)"

        # Simple version comparison - if current version >= required version, skip download
        if (version_compare $current_version $"v($envtest_k8s_version)") >= 0 {
            print "Current envtest version is sufficient, skipping download"
            return
        }
    }

    # Download envtest binaries
    let bucket = $"https://github.com/kubernetes-sigs/controller-tools/releases/download/envtest-v($envtest_k8s_version)"
    let tar_file = $"envtest-v($envtest_k8s_version)-($envtest_arch).tar.gz"
    let dst = ($cluster_api_bin_dir | path join $tar_file)

    if not ($dst | path exists) {
        print "Downloading envtest binaries..."
        let result = do { run-external "curl" "-fL" $"($bucket)/($tar_file)" "-o" $dst } | complete
        if $result.exit_code == 0 {
            print $"Downloaded: ($tar_file)"
        } else {
            print $"Error downloading envtest binaries: ($result.stderr)"
            return
        }
    } else {
        print "Using cached envtest archive"
    }

    # Extract the tar file
    print "Extracting envtest binaries..."
    let result = do {run-external "tar" "-C" $cluster_api_bin_dir "-xzf" $dst "--strip-components=2"} | complete
    if $result.exit_code == 0 {
        print "Extracted envtest binaries"

        # Remove the tar file
        rm $dst
        print "Cleaned up tar file"

        # Remove kubectl since we don't need it
        let kubectl_exe = if ($nu.os-info.name == "windows") {
            ($cluster_api_bin_dir | path join "kubectl.exe")
        } else {
            ($cluster_api_bin_dir | path join "kubectl")
        }

        if ($kubectl_exe | path exists) {
            rm $kubectl_exe
            print "Removed kubectl binary"
        }
    } else {
        print $"Error extracting envtest binaries: ($result.stderr)"
        return
    }
}

# Copy cluster API binaries to mirror directory and create zip
def copy_cluster_api_to_mirror [] {
    let target_os_arch = $"(go env GOOS)_(go env GOARCH)"
    let cluster_api_bin_dir = (pwd | path join "cluster-api" "bin" $target_os_arch)
    let cluster_api_mirror_dir = (pwd | path join "pkg" "clusterapi" "mirror")

    print $"Target OS/Arch: ($target_os_arch)"
    print $"Cluster API bin dir: ($cluster_api_bin_dir)"
    print $"Cluster API mirror dir: ($cluster_api_mirror_dir)"

    # Create directories
    mkdir $cluster_api_bin_dir
    mkdir $cluster_api_mirror_dir

    print "Created cluster API directories"

    # Clean the mirror, but preserve the README file
    if ($cluster_api_mirror_dir | path exists) {
        let zip_files = (ls $cluster_api_mirror_dir | where name =~ ".*\\.zip$")
        if ($zip_files | length) > 0 {
            $zip_files | each { |file| rm $file.name }
            print "Cleaned existing zip files from mirror directory"
        }
    } else {
        print "No existing zip files to clean"
    }

    # Sync envtest if not skipped
    if ($env.SKIP_ENVTEST? | default "n") != "y" {
        print "Syncing envtest binaries..."
        sync_envtest $cluster_api_bin_dir
    } else {
        print "Skipping envtest sync (SKIP_ENVTEST=y)"
    }

    # Check if there are binaries to zip
    let binaries = if ($cluster_api_bin_dir | path exists) {
        ls $cluster_api_bin_dir | where type == file
    } else {
        []
    }

    if ($binaries | length) == 0 {
        print "Warning: No binaries found in cluster API bin directory"
        return
    }

    print $"Found ($binaries | length) binaries to package"

    # Create zip file with all binaries
    let zip_file = ($cluster_api_mirror_dir | path join "cluster-api.zip")

    # Use system zip command for cross-platform compatibility
    cd $cluster_api_bin_dir
    let binary_names = ($binaries | get name | path basename)

    if ($nu.os-info.name == "windows") {
        # On Windows, try PowerShell Compress-Archive if zip is not available
        let zip_result = do {run-external "zip" "-j1" $zip_file ...$binary_names} | complete
        if $zip_result.exit_code != 0 {
            print "zip command not found, trying PowerShell Compress-Archive..."
            let temp_script = "temp_compress.ps1"
            let binary_list = ($binary_names | str join '","')
            $"Compress-Archive -Path \"($binary_list)\" -DestinationPath \"($zip_file)\" -CompressionLevel Optimal -Force" | save $temp_script
            let ps_result = (run-external "powershell" "-ExecutionPolicy" "Bypass" "-File" $temp_script | complete)
            rm $temp_script
            if $ps_result.exit_code != 0 {
                print $"Error creating zip file: ($ps_result.stderr)"
                cd -
                return
            }
        }
    } else {
        let zip_result = do {run-external "zip" "-j1" $zip_file ...$binary_names} | complete
        if $zip_result.exit_code != 0 {
            print $"Error creating zip file: ($zip_result.stderr)"
            cd -
            return
        }
    }

    cd -
    print $"Created cluster API zip: ($zip_file)"
}

# Setup environment variables and paths
def setup_environment [] {
    print "Setting up build environment..."
    print $"Platform: ($nu.os-info.name)"
    print $"Architecture: ($nu.os-info.arch)"

    # Detect platform
    let is_windows = ($nu.os-info.name == "windows")
    let path_sep = if $is_windows { ";" } else { ":" }

    # Check target platform support
    let target_platform = ($env.target_platform? | default "")
    let supported_platforms = ["linux-aarch64", "osx-arm64", "osx-64", "win-64"]

    if $target_platform not-in $supported_platforms and $target_platform != "" {
        print $"Warning: Target platform ($target_platform) not in supported list"
    }

    # Platform-specific environment setup
    if $is_windows {
        print "Setting up Windows environment..."
        $env.CGO_ENABLED = "0"

        # Update PATH
        let build_prefix = ($env.BUILD_PREFIX? | default "C:\\conda")
        let current_path = ($env.PATH? | default "")
        $env.PATH = $"($build_prefix | path join "bin")($path_sep)($build_prefix | path join "go" "bin")($path_sep)($current_path)"

        # Clear compiler flags
        $env.LDFLAGS = ""
        $env.CPPFLAGS = ""
        $env.CFLAGS = ""
        $env.CXXFLAGS = ""
    } else {
        print "Setting up Unix environment..."
        $env.CGO_ENABLED = "0"

        # Update PATH
        let build_prefix = ($env.BUILD_PREFIX? | default "/opt/conda")
        let current_path = ($env.PATH? | default "")
        $env.PATH = $"($build_prefix | path join "bin")($path_sep)($build_prefix | path join "go" "bin")($path_sep)($current_path)"

        # Clear compiler flags
        if "LDFLAGS" in $env { hide-env LDFLAGS }
        if "CPPFLAGS" in $env { hide-env CPPFLAGS }
        if "CFLAGS" in $env { hide-env CFLAGS }
        if "CXXFLAGS" in $env { hide-env CXXFLAGS }
    }

    # Set version and build information
    let version = ($env.PKG_VERSION? | default "unknown")
    $env.SOURCE_GIT_COMMIT = $version
    $env.BUILD_VERSION = $version
    $env.TAGS = "include_gcs include_oss containers_image_openpgp"
    $env.OUTPUT = "openshift-installer"

    print $"Version: ($version)"
    print $"CGO_ENABLED: ($env.CGO_ENABLED)"
    print $"PATH: ($env.PATH)"

    # Navigate to correct source directory (Windows specific behavior)
    if $is_windows {
        print "Looking for source directories..."

        let possible_dirs = [
            $"installer-($version)",
            $"openshift-installer-($version)",
            "openshift-installer",
            "installer"
        ]

        for dir in $possible_dirs {
            if ($dir | path exists) {
                print $"Found and entering directory: ($dir)"
                cd $dir
                break
            }
        }

        print $"Current directory after navigation: (pwd)"
        if ("cmd" | path exists) {
            print $"cmd directory contents: (ls cmd | get name | str join ', ')"
        }
    }

    return {
        is_windows: $is_windows,
        version: $version
    }
}


# Build the main openshift-install binary (based on hack/build.sh)
def hack_build [config: record] {
    let is_windows = $config.is_windows
    let version = $config.version
    let exe_suffix = if $is_windows { ".exe" } else { "" }

    # The functions from "$(dirname "$0")/build-cluster-api.sh" are part of this file.
    # The inclusion is thus not necessary.

    # The go version must be greater or equal to 1.23, enforced by the pixi toml.
    # The go version check has been removed from this script.

    $env.CGO_ENABLED = "0"
    let mode = ($env.MODE? | default "release")

    # Build cluster-api binaries
    let make_result = do {run-external "make" "-C" "cluster-api" "all"} | complete
    if $make_result.exit_code == 0 {
        copy_cluster_api_to_mirror
    } else {
        print $"Warning: cluster-api build failed: ($make_result.stderr), continuing..."
    }

    # Note that the default git_* variables are for the feedstock and not the source.
    let git_commit = ($env.SOURCE_GIT_COMMIT? | default (^git rev-parse --verify 'HEAD^{commit}'))
    let git_tag = ($env.BUILD_VERSION? | default (^git describe --always --abbrev=40 --dirty) )

    let default_arch = ($env.DEFAULT_ARCH? | default "amd64")
    let goflags = ($env.GOFLAGS? | default "-mod=vendor")

    mut gcflags = ""
    mut ldflags = $"-X github.com/openshift/installer/pkg/version.Raw=($git_tag) -X github.com/openshift/installer/pkg/version.Commit=($git_commit) -X github.com/openshift/installer/pkg/version.defaultArch=($default_arch)"
    mut tags = ($env.TAGS? | default "")
    let output = ($env.OUTPUT? | default ("bin/openshift-install"))

    # Configure build mode
    match $mode {
        "release" => {
            $ldflags = $"($ldflags) -s -w"
            if ($tags | str trim | is-empty) {
                $tags = "release"
            } else {
                $tags = $"($tags) release"
            }
        },
        "dev" => {
            $gcflags = "all=-N -l"
        },
        _ => {
            print $"unrecognized mode: ($mode)"
            exit 1
        }
    }

    # Generate data files (skip if SKIP_GENERATION is set)
    if ($env.SKIP_GENERATION? | default "n") != "y" {
        # This step has to be run natively, even when cross-compiling
        with-env {GOOS: "", GOARCH: ""} {
            let generate_result = do {run-external "go" "generate" "./data"} | complete
            if $generate_result.exit_code != 0 {
                print $"Warning: go generate failed: ($generate_result.stderr), continuing..."
            }
        }
    }

    if ($tags | str contains "fipscapable") {
        $env.CGO_ENABLED = "1"
    }

    print "building openshift-install"

    let cmd_dir = "./cmd/openshift-install"

    # Build the arguments for the binary (similar to original script structure)
    let build_args = (
        ["build"]
        # Add goflags if not empty
        | if ($goflags | str trim | is-not-empty) {
            let flag_parts = ($goflags | split row " " | where $it != "")
            $in | append $flag_parts
        } else {
            $in
        }
        # Add gcflags if not empty
        | if ($gcflags | str trim | is-not-empty) {
            $in | append ["-gcflags", $gcflags]
        } else {
            $in
        }
        # Add ldflags
        | append ["-ldflags", $ldflags]
        # Add tags if not empty
        | if ($tags | str trim | is-not-empty) {
            $in | append ["-tags", $tags]
        } else {
            $in
        }
        # Add output and source
        | append ["-o", $"($output)($exe_suffix)", $cmd_dir]
    )

    let build_result = do {run-external "go" ...$build_args} | complete
    if $build_result.exit_code != 0 {
        print $"Error building: ($build_result.stderr)"
        exit 1
    }

    return {
        binary_path: $"($output)($exe_suffix)",
        output: $output,
        exe_suffix: $exe_suffix
    }
}

# Generate license information using go-licenses
def generate_licenses [config: record] {
    print "Generating license information..."

    let is_windows = $config.is_windows

    # Find the correct cmd directory
    let cmd_dir = if ("cmd/openshift-install" | path exists) {
        "./cmd/openshift-install"
    } else if ("cmd/openshift-installer" | path exists) {
        "./cmd/openshift-installer"
    } else {
        print "Warning: Cannot find cmd directory for license generation"
        return
    }

    let licenses_csv = "licenses.csv"
    let licenses_dir = "licenses"

    let csv_result = do {run-external "go-licenses" "csv" $cmd_dir} | complete
    if $csv_result.exit_code == 0 {
        $csv_result.stdout | save -f $licenses_csv
        print $"License CSV saved to ($licenses_csv)"
    } else {
        print $"Warning: go-licenses csv failed: ($csv_result.stderr), creating empty file"
        if $is_windows {
            let null_result = do {run-external "cmd" "/c" $"type nul > ($licenses_csv)"} | complete
            if $null_result.exit_code != 0 {
                "" | save -f $licenses_csv
            }
        } else {
            "" | save -f $licenses_csv
        }
    }

    let save_result = do {run-external "go-licenses" "save" $cmd_dir "--save_path" $licenses_dir} | complete
    if $save_result.exit_code == 0 {
        print $"Licenses saved to ($licenses_dir)/"
    } else {
        print $"Warning: go-licenses save failed: ($save_result.stderr), creating directory"
        mkdir $licenses_dir
    }
}

def main [] {
    print "Building OpenShift installer with Nushell..."
    print $"Current directory: (pwd)"

    # Setup environment and get configuration
    let env_config = (setup_environment)

    # Build the main binary using hack/build.sh logic
    let build_result = (hack_build $env_config)

    # Generate license information
    generate_licenses $env_config

    # Install binaries to PREFIX/bin
    let prefix = ($env.PREFIX? | default "/usr/local")
    let bin_dir = ($prefix | path join "bin")
    let output = $build_result.output
    let exe_suffix = $build_result.exe_suffix
    let binary_path = $build_result.binary_path

    # Copy main binary
    mkdir $bin_dir
    print $"Copying main binary ($output)($exe_suffix) to ($bin_dir)"
    cp $"($output)($exe_suffix)" ($bin_dir | path join $"($output)($exe_suffix)")
    cp $"($output)($exe_suffix)" ($bin_dir | path join $"okd-install($exe_suffix)")
}
