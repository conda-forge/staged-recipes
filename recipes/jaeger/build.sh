#!/bin/bash

mkdir -vp ${PREFIX}/bin;

cp -v cmd/all-in-one/all-in-one-* ${PREFIX}/bin/all-in-one || exit 1;
cp -v cmd/agent/agent-* ${PREFIX}/bin/agent || exit 1;
cp -v cmd/query/query-* ${PREFIX}/bin/query || exit 1;
cp -v cmd/collector/collector-* ${PREFIX}/bin/collector || exit 1;
cp -v cmd/ingester/ingester-* ${PREFIX}/bin/ingester || exit 1;
cp -v examples/hotrod/hotrod-* ${PREFIX}/bin/hotrod || exit 1;

chmod -v 755 ${PREFIX}/bin/* || exit 1;
