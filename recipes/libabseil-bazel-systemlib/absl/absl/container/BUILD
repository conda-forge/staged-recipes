load("@rules_cc//cc:cc_library.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

COMMON_LIBS = ["node_hash_map", "flat_hash_map", "node_hash_set"]

[cc_library(
    name = _lib,
    deps = [
        ":container_memory",
        ":hash_function_defaults",
        ":raw_hash_map",
        "//absl/algorithm:container",
    ],
) for _lib in COMMON_LIBS]

cc_library(
    name = "container_memory",
    deps = [
        "//absl/base:config",
        "//absl/meta:type_traits",
    ],
)

cc_library(
    name = "compressed_tuple",
)

cc_library(
    name = "inlined_vector_internal",
    deps = [
        ":compressed_tuple",
        "//absl/base:core_headers",
        "//absl/meta:type_traits",
        "//absl/types:span",
    ],
)

cc_library(
    name = "inlined_vector",
    deps = [
        ":inlined_vector_internal",
        "//absl/base:core_headers",
        "//absl/base:throw_delegate",
    ],
)

cc_library(
    name = "fixed_array",
    deps = [
        ":compressed_tuple",
        "//absl/algorithm",
        "//absl/base:config",
        "//absl/base:core_headers",
        "//absl/base:dynamic_annotations",
        "//absl/base:throw_delegate",
    ],
)

cc_library(
    name = "layout",
    deps = [
        "//absl/base:config",
        "//absl/base:core_headers",
        "//absl/meta:type_traits",
        "//absl/types:span",
    ],
)

cc_library(
    name = "btree",
    deps = [
        ":common",
        ":compressed_tuple",
        ":container_memory",
        ":layout",
        "//absl/base:core_headers",
        "//absl/base:throw_delegate",
        "//absl/meta:type_traits",
        "//absl/strings:cord",
        "//absl/types:compare",
    ],
)

cc_library(
    name = "flat_hash_set",
    deps = [
        ":container_memory",
        ":hash_function_defaults",
        ":raw_hash_set",
        "//absl/algorithm:container",
        "//absl/base:core_headers",
        "//absl/memory",
    ],
)

cc_library(
    name = "raw_hash_set",
    linkopts = ["-labsl_raw_hash_set"],
    deps = [
        ":common",
        ":compressed_tuple",
        ":container_memory",
        ":hash_policy_traits",
        ":hashtable_debug_hooks",
        ":hashtablez_sampler",
        ":layout",
        "//absl/base:config",
        "//absl/base:core_headers",
        "//absl/base:endian",
        "//absl/meta:type_traits",
        "//absl/numeric:bits",
    ],
)

cc_library(
    name = "raw_hash_map",
    deps = [
        ":container_memory",
        ":raw_hash_set",
        "//absl/base:throw_delegate",
    ],
)

cc_library(
    name = "hash_function_defaults",
    deps = [
        "//absl/base:config",
        "//absl/strings",
        "//absl/strings:cord",
    ],
)

cc_library(
    name = "common",
    deps = [
        "//absl/meta:type_traits",
        "//absl/types:optional",
    ],
)

cc_library(
    name = "hash_policy_traits",
    deps = ["//absl/meta:type_traits"],
)

cc_library(
    name = "hashtable_debug_hooks",
    deps = [
        "//absl/base:config",
    ],
)

cc_library(
    name = "hashtablez_sampler",
    linkopts = ["-labsl_hashtablez_sampler"],
    deps = [
        "//absl/base:core_headers",
        "//absl/base:exponential_biased",
        "//absl/debugging:stacktrace",
        "//absl/synchronization",
    ],
)
