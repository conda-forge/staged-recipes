@echo on
set "ENV_D=%PREFIX%\etc\conda\env_vars.d"
set "FWD_PREFIX=%PREFIX:\=/%"
set ENV_JSON={"OPENSYSML_BINARY":"%FWD_PREFIX%/Library/bin/sysml-grpc.exe"}

md "%ENV_D%"                                    || exit 3
cd "%ENV_D%"                                    || exit 4
echo "%ENV_JSON%" > sysml-grpc.json             || exit 5
dir                                             || exit 6
type sysml-grpc.json                            || exit 7
