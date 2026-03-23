load("@rules_cc//cc:cc_library.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "parse",
    linkopts = ["-labsl_flags_parse"],
)

cc_library(
    name = "flag",
    linkopts = ["-labsl_flags_internal", "-labsl_flags_marshalling", "-labsl_flags_reflection"],
)
