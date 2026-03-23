load("@rules_cc//cc:cc_library.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "stacktrace",
    linkopts = ["-labsl_stacktrace"],
    deps = [
        ":debugging_internal",
    ],
)

cc_library(
    name = "symbolize",
    linkopts = ["-labsl_symbolize"],
    deps = [
        ":debugging_internal",
        ":demangle_internal",
        "//absl/base",
        "//absl/base:dynamic_annotations",
        "//absl/base:malloc_internal",
        "//absl/base:raw_logging_internal",
        "//absl/strings",
    ],
)

cc_library(
    name = "debugging_internal",
    linkopts = ["-labsl_debugging_internal"],
    deps = [
        "//absl/base:dynamic_annotations",
        "//absl/base:errno_saver",
        "//absl/base:raw_logging_internal",
    ],
)

cc_library(
    name = "demangle_internal",
    linkopts = ["-labsl_demangle_internal"],
    deps = [
        "//absl/base",
    ],
)
