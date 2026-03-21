load("@rules_java//java:defs.bzl", "java_library")
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library", "cc_test", "objc_library")
load("//bazel/toolchains:proto_lang_toolchain.bzl", "proto_lang_toolchain")
load("//bazel:cc_proto_library.bzl", "cc_proto_library")
load("//bazel:proto_library.bzl", "proto_library")

licenses(["notice"])

filegroup(
    name = "LICENSE",
    visibility = ["//visibility:public"],
)

alias(
    name = "license",
    actual = ":LICENSE",
    visibility = ["//visibility:public"],
)

# Map of all well known protos.
# name => (include path, imports)
WELL_KNOWN_PROTO_MAP = {
    "any": ("google/protobuf/any.proto", ["descriptor"]),
    "api": (
        "google/protobuf/api.proto",
        [
            "descriptor",
            "source_context",
            "type",
        ],
    ),
    "compiler_plugin": (
        "google/protobuf/compiler/plugin.proto",
        ["descriptor"],
    ),
    "descriptor": ("google/protobuf/descriptor.proto", []),
    "duration": ("google/protobuf/duration.proto", ["descriptor"]),
    "empty": ("google/protobuf/empty.proto", ["descriptor"]),
    "field_mask": ("google/protobuf/field_mask.proto", ["descriptor"]),
    "source_context": ("google/protobuf/source_context.proto", ["descriptor"]),
    "struct": ("google/protobuf/struct.proto", ["descriptor"]),
    "timestamp": ("google/protobuf/timestamp.proto", ["descriptor"]),
    "type": (
        "google/protobuf/type.proto",
        [
            "any",
            "descriptor",
            "source_context",
        ],
    ),
    "wrappers": ("google/protobuf/wrappers.proto", ["descriptor"]),
}

RELATIVE_WELL_KNOWN_PROTOS = [proto[1][0] for proto in WELL_KNOWN_PROTO_MAP.items()]

genrule(
    name = "link_proto_files",
    outs = RELATIVE_WELL_KNOWN_PROTOS,
    cmd = """
      for i in $(OUTS); do
        f=$${i#$(@D)/}
        mkdir -p $(@D)/$${f%/*}
        ln -sf $(PROTOBUF_INCLUDE_PATH)/$$f $(@D)/$$f
      done
    """,
)

cc_library(
    name = "protobuf",
    linkopts = ["-lprotobuf", "-labsl_cord", "-labsl_cord_internal", "-labsl_cordz_functions", "-labsl_cordz_handle", "-labsl_cordz_info", "-labsl_cordz_sample_token", "-labsl_log_flags", "-labsl_log_globals", "-labsl_log_initialize", "-labsl_log_internal_check_op", "-labsl_log_internal_conditions", "-labsl_log_internal_format", "-labsl_log_internal_globals", "-labsl_log_internal_log_sink_set", "-labsl_log_internal_message", "-labsl_log_internal_nullguard", "-labsl_log_internal_proto", "-labsl_log_severity", "-labsl_log_sink"],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "protobuf_headers",
    linkopts = ["-lprotobuf", "-labsl_cord", "-labsl_cord_internal", "-labsl_cordz_functions", "-labsl_cordz_handle", "-labsl_cordz_info", "-labsl_cordz_sample_token", "-labsl_log_flags", "-labsl_log_globals", "-labsl_log_initialize", "-labsl_log_internal_check_op", "-labsl_log_internal_conditions", "-labsl_log_internal_format", "-labsl_log_internal_globals", "-labsl_log_internal_log_sink_set", "-labsl_log_internal_message", "-labsl_log_internal_nullguard", "-labsl_log_internal_proto", "-labsl_log_severity", "-labsl_log_sink"],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "protoc_lib",
    linkopts = ["-lprotoc", "-lprotobuf", "-labsl_log_internal_check_op", "-labsl_log_internal_message", "-labsl_flags_reflection", "-labsl_hash", "-labsl_raw_hash_set", "-labsl_raw_logging_internal"],
    visibility = ["//visibility:public"],
)

LIB_ALIASES = ["type_resolver", "differencer", "json_util", "delimited_message_util", "time_util"]

[alias(
    name = _alias,
    actual = "protobuf",
    visibility = ["//visibility:public"],
) for _alias in LIB_ALIASES]

genrule(
    name = "protoc",
    outs = ["protoc.bin"],
    cmd = "ln -s $(PROTOC_PREFIX)/bin/protoc $@",
    executable = 1,
    visibility = ["//visibility:public"],
)

cc_proto_library(
    name = "cc_wkt_protos",
    visibility = ["//visibility:public"],
)

java_library(
    name = "protobuf_java",
    exports = ["@maven_protobuf//:original_com_google_protobuf_protobuf_java"],
    visibility = ["//visibility:public"],
)

java_library(
    name = "protobuf_java_util",
    exports = ["@maven_protobuf//:original_com_google_protobuf_protobuf_java_util"],
    visibility = ["//visibility:public"],
)

proto_lang_toolchain(
    name = "cc_toolchain",
    blacklisted_protos = [proto + "_proto" for proto in WELL_KNOWN_PROTO_MAP.keys()],
    command_line = "--cpp_out=$(OUT)",
    runtime = ":protobuf",
    visibility = ["//visibility:public"],
)

proto_lang_toolchain(
    name = "java_toolchain",
    command_line = "--java_out=$(OUT)",
    runtime = ":protobuf_java",
    visibility = ["//visibility:public"],
)

[proto_library(
    name = proto[0] + "_proto",
    srcs = [proto[1][0]],
    visibility = ["//visibility:public"],
    deps = [dep + "_proto" for dep in proto[1][1]],
) for proto in WELL_KNOWN_PROTO_MAP.items()]

[cc_proto_library(
    name = proto[0] + "_cc_proto",
    deps = [":" + proto[0] + "_proto"],
    visibility = ["//visibility:public"],
) for proto in WELL_KNOWN_PROTO_MAP.items()]
