#!/bin/bash
set -euxo pipefail

# Build the jira binary
go build -v -o "${PREFIX}/bin/jira" ./cmd/jira
