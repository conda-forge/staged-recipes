#!/usr/bin/env nu

# Node-RED conda build script using Nushell

def main [] {
    print "Starting Node-RED conda build process..."

    # Handle cross-compilation setup for macOS ARM64
    if ($env.target_platform?) == "osx-arm64" {
        $env.npm_config_arch = "arm64"
    }

    # Handle cross-compilation node symlink
    if ($env.build_platform?) != ($env.target_platform?) and ($env.build_platform?) != null {
        let node_path = $env.PREFIX | path join "bin" "node"
        let build_node_path = $env.BUILD_PREFIX | path join "bin" "node"

        if ($node_path | path exists) {
            ^rm $node_path
        }
        ^ln -s $build_node_path $node_path
    }

    # Create package archive
    ^npm pack --ignore-scripts

    # Install Node-RED globally
    let package_file = $env.SRC_DIR | path join $"($env.PKG_NAME)-($env.PKG_VERSION).tgz"

    ^npm install --global --build-from-source $package_file

    # Generate license report on all platforms
    ^pnpm install
    ^pnpm-licenses generate-disclaimer --prod --output-file ($env.SRC_DIR | path join "third-party-licenses.txt")

    # Set up service configuration
    let share_dir = if ($nu.os-info.name == "windows") { $env.LIBRARY_PREFIX | path join "share" } else { $env.PREFIX | path join "share" }
    let pkg_share_dir = $share_dir | path join $env.PKG_NAME
    let service_target = $pkg_share_dir | path join "service.yaml"
    let service_source = $env.RECIPE_DIR | path join "service.yaml"

    mkdir $share_dir
    mkdir $pkg_share_dir
    cp $service_source $service_target

    if ($nu.os-info.name != "windows") {
        ^chmod 644 $service_target
    }

    print "Build completed successfully!"
}



# Run main function
main
