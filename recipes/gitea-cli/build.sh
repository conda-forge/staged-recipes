#!/usr/bin/env bash
set -euxo pipefail

go-licenses save ./cmd/gt --save_path library_licenses

go build \
  -v \
  -trimpath \
  -ldflags="-s -w -X gitea.dev/cli/internal/version.Version=${PKG_VERSION} -X gitea.dev/cli/internal/version.Tags=" \
  -o "${PREFIX}/bin/gt" \
  ./cmd/gt

go run ./tools/cli-docs --out docs/generated

install -d "${PREFIX}/share/bash-completion/completions"
install -d "${PREFIX}/share/fish/vendor_completions.d"
install -d "${PREFIX}/share/man/man1"
install -d "${PREFIX}/share/zsh/site-functions"

install -m 644 docs/generated/completion/gt.bash "${PREFIX}/share/bash-completion/completions/gt"
install -m 644 docs/generated/completion/gt.fish "${PREFIX}/share/fish/vendor_completions.d/gt.fish"
install -m 644 docs/generated/man/*.1 "${PREFIX}/share/man/man1/"
install -m 644 docs/generated/completion/_gt "${PREFIX}/share/zsh/site-functions/_gt"
