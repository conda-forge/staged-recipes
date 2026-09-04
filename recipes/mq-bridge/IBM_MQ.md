# IBM MQ

The IBM MQ transport is the only endpoint whose native client `mq-bridge` cannot
ship or build for you. IBM does not redistribute it under a licence that allows
that, and it is not on conda-forge, so the client has to be installed
separately. Everything else about the transport is ordinary Rust: the wire work
is done by the [`mqi`](https://crates.io/crates/mqi) and
[`libmqm-sys`](https://crates.io/crates/libmqm-sys) wrapper crates.

Nothing proprietary is vendored into this repository. No IBM headers, libraries
or archives are checked in, and the default build never needs them.

Three audiences, and they need different things:

- **Running `mq-bridge-app`** — the endpoint is already compiled into any build
  made with `full`, `full-dynamic` or `full-static-ibm-mq`, so there is nothing
  to rebuild. Install the client, point the process at it, write a route. See
  [Using it from `mq-bridge-app`](#using-it-from-mq-bridge-app).
- **Depending on the `mq-bridge` crate** — pick a feature, build an endpoint in
  code or load one from YAML. See
  [Using it from the `mq-bridge` crate](#using-it-from-the-mq-bridge-crate).
- **Using the Python bindings** — same story as the app: already compiled in,
  so only the client install matters. See
  [Using it from Python](#using-it-from-python).

All three share the same client install and the same runtime lookup, described
first.

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

**`MQ_HOME` is not one of them.** It is read by `build.rs`, and only on the
`ibm-mq-static` path. Setting it alone does nothing for a dlopen build; use
`MQ_INSTALLATION_PATH`, or put the library directory on the platform's search
path so candidate 3 finds it.

## Using it from `mq-bridge-app`

### Confirm the endpoint is compiled in

The app's `full` feature set includes the engine's `ibm-mq`, so a stock
`cargo install mq-bridge-app`, a conda-forge `mq-bridge-app`, or any build made
with `full-dynamic` already carries the endpoint. Nothing needs rebuilding.

One wrinkle is worth knowing before you go looking for it in the UI. The
`/features` endpoint — which is what the web UI's endpoint pickers read — reports
`ibm_mq` from the *app crate's* own `ibm-mq` feature, and `full` does not turn
that one on:

```sh
curl http://localhost:9091/features
# => {"ibm_mq":false, "kafka":true, ...}
```

`ibm_mq: false` there does **not** mean the endpoint is missing. A config-driven
`ibmmq:` route works either way; only the UI's picker hides the type. To get
both, build with the app feature as well:

```sh
cargo install mq-bridge-app --features ibm-mq
```

### Point the process at the client

The app does not resolve the client itself — it inherits whatever the engine's
loader finds, so the rules above apply verbatim. In practice:

```sh
export MQ_INSTALLATION_PATH=/opt/mqm
mqb --config routes.yml
```

For a service manager, set it in the unit rather than in a shell:

```ini
# /etc/systemd/system/mq-bridge.service
[Service]
Environment=MQ_INSTALLATION_PATH=/opt/mqm
Environment=MQ_PASSWORD=…
ExecStart=/usr/bin/mq-bridge-app --config /etc/mq-bridge/routes.yml
```

### A route in the config file

The endpoint key is **`ibmmq`** — one word, no underscore. `url` is IBM's
`host(port)` form, not a URI scheme; a comma-separated list gives client-side
failover.

```yaml
log_level: info

routes:
  orders_from_mq:
    input:
      ibmmq:
        url: "mq1.example.com(1414),mq2.example.com(1414)"
        queue_manager: "QM1"
        channel: "DEV.APP.SVRCONN"
        queue: "DEV.QUEUE.1"
        username: "app"
        password: "${MQ_PASSWORD}"
    output:
      nats:
        subject: "orders.raw"
        url: "nats://localhost:4222"
```

Set `topic` instead of `queue` for publish/subscribe; a consumer with `topic`
runs in subscriber mode. `queue` defaults to the route name if both are omitted.
See [REFERENCE.md](REFERENCE.md) for every field.

`${MQ_PASSWORD}` is the app's config-value form, expanded when the config loads;
`${VAR:-default}` supplies a fallback, and a `.env` file in the working
directory is read automatically. Do not reach for `${env:VAR}` here — that is a
different, narrower mechanism used by message templates and the encryption key,
and it is not applied to endpoint fields.

### One-off drains from the command line

`mqb copy` takes endpoint URIs rather than a config file, which is the quickest
way to move a queue somewhere once. Both `ibmmq://` and `ibm-mq://` are
accepted, and the config fields become query parameters:

```sh
export MQ_INSTALLATION_PATH=/opt/mqm
mqb copy \
  'ibmmq://mq1.example.com(1414)?queue_manager=QM1&channel=DEV.APP.SVRCONN&queue=DEV.QUEUE.1&username=app' \
  'file:///tmp/orders.jsonl?format=json' \
  --drain --verbose
```

`--drain` exits once the queue is empty; without it the copy runs as a
continuous bridge until Ctrl-C.

### What a missing client looks like

The route fails on first connect, and the error is classified non-retryable, so
it fails fast instead of reconnecting forever:

```
failed to load IBM MQ client library (tried ["/opt/mqm/lib64/libmqm_r.so",
"/opt/mqm/lib/libmqm_r.so", "libmqm_r.so"]; last error: …). Install the IBM MQ
redistributable client and ensure it is on the library search path, or set
MQB_IBM_MQ_LIB to the full path of the libmqm_r library.
```

Read the list: it is every path that was tried, in order. An empty-looking list
usually means neither `MQB_IBM_MQ_LIB` nor `MQ_INSTALLATION_PATH` reached the
process — a common outcome when the app runs under a service manager that does
not inherit your shell environment. A populated list with a
"wrong ELF class" or "no suitable image found" error means the client is there
but the wrong architecture.

Other routes in the same config are unaffected; only the IBM MQ one stops.

## Using it from the `mq-bridge` crate

### Choosing the feature

```toml
[dependencies]
mq-bridge = { version = "0.4", features = ["ibm-mq"] }
```

That is the dlopen build: it compiles with no IBM SDK present, and the client is
needed only at runtime. For the link-time binding instead:

```toml
mq-bridge = { version = "0.4", features = ["ibm-mq-static"] }
```

Unlike `sqlx`, neither feature needs a `link-static` / `link-dynamic` companion
— those two select how librdkafka and SQLite are obtained, and IBM MQ is not
part of that choice. Enabling `ibm-mq` alongside `ibm-mq-static` forces the
link-time path, and then the SDK is required at build.

### Building an endpoint in code

`IbmMqConfig` is an ordinary builder, and `Endpoint::new` wraps it:

```rust
use mq_bridge::models::{Endpoint, EndpointType, IbmMqConfig};
use mq_bridge::Route;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let mq = IbmMqConfig::new("mq1.example.com(1414)", "QM1", "DEV.APP.SVRCONN")
        .with_queue("DEV.QUEUE.1")
        .with_credentials("app", std::env::var("MQ_PASSWORD")?);

    let input = Endpoint::new(EndpointType::IbmMq(mq));
    let output = Endpoint::new_memory("orders", 1024);

    Route::new(input, output).deploy("orders_from_mq").await?;
    Ok(())
}
```

`Publisher::new(endpoint)` gives the send-only half if you want to publish to a
queue rather than run a route.

### Loading the same route from YAML

`Endpoint` deserializes from the config shown above, so a library user can keep
the connection details out of the binary:

```rust
let endpoint: mq_bridge::models::Endpoint = serde_yaml_ng::from_str(
    r#"
    ibmmq:
      url: "mq1.example.com(1414)"
      queue_manager: "QM1"
      channel: "DEV.APP.SVRCONN"
      queue: "DEV.QUEUE.1"
    "#,
)?;
```

### Checking before you connect

On the dlopen build the client's absence is only discovered on first connect. If
you would rather decide up front — to skip a subsystem, or to fail startup with
your own message — ask directly:

```rust
if mq_bridge::endpoints::ibm_mq::ibm_mq_client_available() {
    // deploy the IBM MQ routes
}
```

It attempts the same load the endpoint would, and returns `true` unconditionally
on an `ibm-mq-static` build, where the client is bound at link time. The
integration tests use it to skip themselves where no client is installed.

## Using it from Python

The bindings need no special build either: `mq-bridge/full` and
`full-dynamic` both include `ibm-mq`, which covers the conda-forge
`mq-bridge-py` package and upstream's `full` PyPI wheel. Only the client
install and the runtime lookup above apply.

A complete, runnable example is
[`examples/ibm-mq-input.py`](../python/mq-bridge-py/examples/ibm-mq-input.py):
it consumes a queue, hands every message to a Python callable and discards what
the callable returns. In outline:

```python
import os
import mq_bridge

route_config = {
    "input": {
        "ibmmq": {
            "url": "mq1.example.com(1414)",
            "queue_manager": "QM1",
            "channel": "DEV.APP.SVRCONN",
            "queue": "DEV.QUEUE.1",
            "username": "app",
            "password": os.environ["MQ_PASSWORD"],
        }
    },
    "output": "null",
}

def process_message(message):
    print(len(message.payload), message.metadata)
    return None       # ack without publishing

mq_bridge.Route.from_config(route_config, "orders_from_mq") \
    .with_handler(process_message) \
    .run()
```

Three things that catch people out:

- The import is **`mq_bridge`**. `mq-bridge-py` is the distribution name, not
  the module name.
- The route body takes **`input`** and **`output`**, the same two keys as the
  YAML config. `Route.from_config` accepts a bare route body like this one, or a
  whole config plus a route name.
- A handler's **return value is the published message**: bytes, a `str`, a
  `dict` or a `mq_bridge.Message` go to the output endpoint, while `None`
  acknowledges without publishing. Raise `mq_bridge.RetryableError` for
  redelivery, `mq_bridge.NonRetryableError` to fail the message.

The environment variables are read by the same loader as everywhere else, so
export `MQ_INSTALLATION_PATH` before starting the interpreter — a missing client
surfaces as the non-retryable error shown above, raised out of the route rather
than at import time.

## Building with the link-time binding

Only needed for `ibm-mq-static`; the dlopen build needs none of this.

```sh
export MQ_INSTALLATION_PATH=/opt/mqm
cargo build --features ibm-mq-static
cargo build --features full-static-ibm-mq   # whole set, link-time IBM MQ
```

With pixi: `pixi run build-static-ibm-mq`. The dlopen equivalents are
`pixi run build-static` (`--features full`) and `pixi run build-dynamic`
(`--features full-dynamic`).

`build.rs` adds `$MQ_INSTALLATION_PATH/lib64` (or `lib` on 32-bit) to the link
search path and records it as an rpath, so the resulting binary finds
`libmqm_r` without `LD_LIBRARY_PATH`. It falls back to `MQ_HOME`, then
`/opt/mqm`. This applies **only** to `ibm-mq-static`; the dlopen build gets no
rpath, because it never consults the link search path.

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

## Redistribution

IBM's client is redistributable under IBM's own terms, not under this project's
MIT licence. If you ship binaries together with the client, include IBM's
licence files from `$MQ_INSTALLATION_PATH/licenses` and follow IBM's
redistribution conditions. Shipping `mq-bridge` alone carries no such
obligation: the dlopen build contains no IBM code.
