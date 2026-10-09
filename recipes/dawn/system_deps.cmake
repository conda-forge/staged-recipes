# Injected with CMAKE_PROJECT_Dawn_INCLUDE so that the dependencies below come
# from the host environment instead of Dawn's (absent) git submodules. Dawn's
# third_party/CMakeLists.txt skips vendored copies when these targets exist.
find_package(absl CONFIG REQUIRED)
find_package(SPIRV-Headers CONFIG REQUIRED)

# Dawn refers to the headers by their in-tree target name.
add_library(SPIRV-Headers ALIAS SPIRV-Headers::SPIRV-Headers)

# DAWN_ENABLE_VULKAN is not defined yet at this point; Vulkan is enabled
# by default everywhere except Apple platforms. SPIRV-Tools is only needed for
# Tint's SPIR-V support, which is built together with the Vulkan backend.
if(NOT APPLE)
  find_package(SPIRV-Tools CONFIG REQUIRED)
  find_package(SPIRV-Tools-opt CONFIG REQUIRED)

  # Tint's SPIR-V reader includes SPIRV-Tools private headers ("source/opt/...").
  find_path(SPIRV_TOOLS_PRIVATE_INCLUDE_DIR source/opt/build_module.h
    PATH_SUFFIXES spirv-tools-private REQUIRED)
  set_property(TARGET SPIRV-Tools-opt APPEND PROPERTY
    INTERFACE_INCLUDE_DIRECTORIES "${SPIRV_TOOLS_PRIVATE_INCLUDE_DIR}")

  find_package(VulkanHeaders CONFIG REQUIRED)
  find_package(VulkanUtilityLibraries CONFIG REQUIRED)
endif()
