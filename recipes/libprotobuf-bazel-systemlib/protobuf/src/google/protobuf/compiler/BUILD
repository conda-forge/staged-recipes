genrule(
    name = "protoc_minimal",
    outs = ["protoc_minimal.bin"],
    cmd = "ln -s $(PROTOC_PREFIX)/bin/protoc $@",
    executable = 1,
    visibility = ["//visibility:public"],
)
