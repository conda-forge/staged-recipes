# IBM MQ

The IBM MQ transport is the only endpoint whose native client `mq-bridge` cannot
ship or build for you. IBM does not redistribute it under a licence that allows
that, and it is not on conda-forge, so the client has to be installed
separately. Everything else about the transport is ordinary Rust: the wire work
is done by the [`mqi`](https://crates.io/crates/mqi) and
[`libmqm-sys`](https://crates.io/crates/libmqm-sys) wrapper crates.

Nothing proprietary is vendored into this repository. No IBM headers, libraries
or archives are checked in, and the default build never needs them.

## The two ways to reach the client

| | `ibm-mq` (default) | `ibm-mq-static` |
| --- | --- | --- |
| IBM client needed to **build** | no | **yes** |
| IBM client needed to **run** | only if a route uses an IBM MQ endpoint | always, or the binary will not start |
| How it is found | `dlopen` on first connect | `DT_NEEDED`, resolved by the loader at startup |
| Missing client shows up as | a non-retryable error on that one route | the process failing to start |
| In `full` | yes | no — use `full-static-ibm-mq` |

`ibm-mq` is in the `full` feature set precisely because it costs nothing: with
no client installed the crate still builds, and only a route that actually opens
an IBM MQ endpoint fails, and it fails fast rather than reconnecting forever.

A note on the name: **`ibm-mq-static` does not statically link anything.**
`libmqm_r` is a shared object either way — IBM ships no static archive. The
difference is *when* it is resolved: at process start for `ibm-mq-static`,
versus on first connect for `ibm-mq`. The feature is named for the build-time
binding, not for static linking.

## Installing the client

The redistributable client is a self-contained tree and needs no root to use,
only somewhere to unpack it. Pick the archive for your platform from
[IBM's redistributable client directory](https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqdev/redist/).

`mq-bridge` builds against capability level **9.3.0.0** — 9.2 is end of life,
and 9.3 is what makes the password-protected key repositories described below
work — so install 9.3.0.0 or later.

```sh
# Linux x86-64. This is what .github/workflows/ibm-mq.yml does.
curl -fsSLO https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqdev/redist/9.3.0.0-IBM-MQC-Redist-LinuxX64.tar.gz
sudo mkdir -p /opt/mqm
sudo tar -xzf 9.3.0.0-IBM-MQC-Redist-LinuxX64.tar.gz -C /opt/mqm
export MQ_INSTALLATION_PATH=/opt/mqm
```

`/opt/mqm` is only a convention. Any readable directory works as long as
`MQ_INSTALLATION_PATH` points at it.

### How the runtime loader finds it

On the `ibm-mq` (dlopen) build, `load_ibm_mq_library()` in
`src/endpoints/ibm_mq.rs` tries these in order and takes the first that loads:

1. `$MQB_IBM_MQ_LIB` — a full path to the library file. Use this when the
   install does not follow the usual layout.
2. `$MQ_INSTALLATION_PATH/lib64/<lib>` then `$MQ_INSTALLATION_PATH/lib/<lib>`.
3. the bare library name, leaving it to the platform's search path
   (`LD_LIBRARY_PATH`, `DYLD_LIBRARY_PATH`, `PATH` on Windows).

`<lib>` is `libmqm_r.so` on Linux, `libmqm_r.dylib` on macOS and `mqm.dll` on
Windows. If every candidate fails, the error lists each path it tried and the
last OS error — that message is the fastest way to diagnose a bad install.

## Enabling the transport

### On the dlopen build (no client needed at build time)

```sh
cargo build --features ibm-mq          # just this transport
cargo build --features full            # or the whole set, which includes it
```

With pixi: `pixi run build-static`, which is `--release --features full`.

### On the link-time build (client required at build time)

```sh
export MQ_INSTALLATION_PATH=/opt/mqm
cargo build --features ibm-mq-static
cargo build --features full-static-ibm-mq   # whole set, link-time IBM MQ
```

With pixi: `pixi run build-static-ibm-mq`.

`build.rs` adds `$MQ_INSTALLATION_PATH/lib64` (or `lib` on 32-bit) to the link
search path and records it as an rpath, so the resulting binary finds
`libmqm_r` without `LD_LIBRARY_PATH`. It falls back to `MQ_HOME`, then
`/opt/mqm`. This applies **only** to `ibm-mq-static`; the dlopen build gets no
rpath, because it never consults the link search path.

### Configuring a route

`url` is IBM's `host(port)` form, not a URI scheme. A comma-separated list
gives client-side failover.

```yaml
orders_from_mq:
  input:
    ibm_mq:
      url: "mq1.example.com(1414),mq2.example.com(1414)"
      queue_manager: "QM1"
      channel: "DEV.APP.SVRCONN"
      queue: "DEV.QUEUE.1"
      username: "app"
      password: "${env:MQ_PASSWORD}"
  output:
    nats:
      subject: "orders.raw"
      url: "nats://localhost:4222"
```

Set `topic` instead of `queue` for publish/subscribe; a consumer with `topic`
runs in subscriber mode. See [REFERENCE.md](REFERENCE.md) for every field.

## TLS

IBM MQ does not consume PEM files, so the `tls` block keeps the generic field
*names* for config parity but carries MQ-native meaning:

- `tls.cert_file` (alias `key_repository`) is a **CMS key repository stem**, not
  a PEM file: `/path/to/tls` refers to `/path/to/tls.kdb`.
- The repository is either passwordless, backed by a `.sth` stash file beside
  the `.kdb`, or password-protected via `tls.cert_password` (alias
  `key_repository_password`), which needs a client and server at 9.3.0.0+.

`tests/integration/docker-compose/ibm-mq-certs/` holds a throwaway repository
(`client.kdb` + `client.sth`) used by the integration tests. Those are test
fixtures, not redistributed IBM software.

## Verifying an install

```sh
# Does the client load at all? Ignored by default, so name it explicitly.
MQ_INSTALLATION_PATH=/opt/mqm cargo test --no-default-features \
  --features ibm-mq -- --ignored loads_client
```

The full IBM MQ integration suite runs against a containerised queue manager;
see `tests/integration/docker-compose/ibm_mq.yml` and the `ibm-mq` job in
`.github/workflows/ibm-mq.yml`. Those tests skip themselves when no client is
present, which is why a normal `cargo test` passes on a machine with no IBM
software at all.
