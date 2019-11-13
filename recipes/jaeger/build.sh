#!/bin/bash
if [ `uname` = "Darwin" ]; then
    export OSNAME="darwin"
else
    export OSNAME="linux"
fi

set -x
pushd src/github.com/jaegertracing/jaeger
dep ensure -v
make install-tools
make build-ui
make "build-binaries-${OSNAME}"
mkdir -vp "${PREFIX}/bin"
cp -v "cmd/all-in-one/all-in-one-${OSNAME}" "${PREFIX}/bin/jaeger-all-in-one"
cp -v "cmd/agent/agent-${OSNAME}" "${PREFIX}/bin/jaeger-agent"
cp -v "cmd/query/query-${OSNAME}" "${PREFIX}/bin/jaeger-query"
cp -v "cmd/collector/collector-${OSNAME}" "${PREFIX}/bin/jaeger-collector"
cp -v "cmd/ingester/ingester-${OSNAME}" "${PREFIX}/bin/jaeger-ingester"
cp -v "examples/hotrod/hotrod-${OSNAME}" "${PREFIX}/bin/jaeger-hotrod"
chmod -v 755 "${PREFIX}/bin/jaeger-all-in-one"
chmod -v 755 "${PREFIX}/bin/jaeger-agent"
chmod -v 755 "${PREFIX}/bin/jaeger-query"
chmod -v 755 "${PREFIX}/bin/jaeger-collector"
chmod -v 755 "${PREFIX}/bin/jaeger-ingester"
chmod -v 755 "${PREFIX}/bin/jaeger-hotrod"
