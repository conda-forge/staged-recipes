//  mq-bridge
//  © Copyright 2025, by Marco Mengelkoch
//  Licensed under MIT License, see License file for more details
//  git clone https://github.com/marcomq/mq-bridge
//! Move messages between brokers, databases, files, HTTP services, and in-memory
//! channels without coupling application code to a specific transport.
//!
//! `mq-bridge` is an asynchronous, embeddable integration library. It gives each
//! transport the same message, consumer, and publisher interfaces, then composes
//! them into routes. A route can transform, filter, batch, retry, rate-limit,
//! deduplicate, or fan out messages before they reach their destination.
//!
//! Unlike a standalone message broker or ETL service, `mq-bridge` runs inside
//! your Rust application. If you prefer a zero-code service configured with YAML,
//! see [`mq-bridge-app`](https://github.com/marcomq/mq-bridge/tree/main/apps/mq-bridge-app).
//!
//! # Quick start
//!
//! Every endpoint implements the same [`traits::MessagePublisher`] interface.
//! This example uses an in-memory endpoint, so it runs without external services:
//!
//! ```
//! use mq_bridge::{
//!     CanonicalMessage,
//!     endpoints::memory::MemoryPublisher,
//!     traits::MessagePublisher,
//! };
//!
//! # #[tokio::main]
//! # async fn main() -> anyhow::Result<()> {
//! let publisher = MemoryPublisher::new_local("docs-quick-start", 16);
//! let channel = publisher.channel();
//!
//! publisher
//!     .send(CanonicalMessage::from("hello from mq-bridge"))
//!     .await?;
//!
//! let messages = channel.drain_messages();
//! assert_eq!(messages[0].get_payload_str(), "hello from mq-bridge");
//! # Ok(())
//! # }
//! ```
//!
//! Replace the memory endpoint with Kafka, NATS, AMQP, MQTT, MongoDB, SQL,
//! HTTP, WebSocket, or another supported endpoint without changing the message
//! model. Transport integrations are enabled with [Cargo features](#cargo-features).
//!
//! # Core concepts
//!
//! - [`CanonicalMessage`] is the transport-independent payload and metadata format.
//! - [`models::Endpoint`] configures a message source or destination.
//! - [`Route`] connects an input endpoint to an output endpoint and optionally
//!   applies a handler.
//! - [`Publisher`] creates a reusable publisher from endpoint configuration.
//! - [`traits::MessageConsumer`] and [`traits::MessagePublisher`] are the extension
//!   points for custom transports.
//! - [`middleware`] contains reusable reliability and processing layers.
//!
//! Most applications work through [`Route`] and [`Publisher`]. Direct consumer
//! usage is available when an application needs to control acknowledgement,
//! batching, and concurrency itself.
//!
//! # Cargo features
//!
//! The core crate has no default features. Enable only the integrations your
//! application uses:
//!
//! ```toml
//! [dependencies]
//! mq-bridge = { version = "0.4", features = ["kafka", "http"] }
//! ```
//!
//! Common feature groups include:
//!
//! - `middleware` — metrics, deduplication, compression, and encryption.
//! - `portable` — integrations that build on common operating systems without
//!   specialized native SDKs.
//! - `full` — all supported integrations; some require native build tools or
//!   runtime libraries.
//!
//! See the [README feature matrix](https://github.com/marcomq/mq-bridge#backend-features--configuration)
//! for individual transports, platform requirements, and configuration examples.
//!
//! # Where to go next
//!
//! - Start with [`Route`], [`Publisher`], and [`CanonicalMessage`] for the primary API.
//! - Browse [`endpoints`] for transport implementations and [`models`] for their
//!   configuration types.
//! - Read the [architecture guide](https://github.com/marcomq/mq-bridge/blob/dev/docs/ARCHITECTURE.md)
//!   for routing, handlers, batching, and delivery semantics.
//! - Read the [project README](https://github.com/marcomq/mq-bridge) for complete
//!   setup and backend-specific examples.
//!
//! # Reliability model
//!
//! Publishing can distinguish success, partial success, retryable failure, and
//! permanent failure. Consumers return explicit commit callbacks, allowing routes
//! to preserve correct acknowledgement ordering for both cumulative-ack brokers
//! and transports with independent acknowledgements. See [`SentBatch`],
//! [`ReceivedBatch`], and [`traits::MessageDisposition`] for the underlying types.

#![warn(rustdoc::broken_intra_doc_links)]
#![warn(rustdoc::missing_crate_level_docs)]

// --- Native linkage guards ---------------------------------------------------
//
// `link-static` and `link-dynamic` select how librdkafka and SQLite are
// obtained. They are mutually exclusive because sqlx's `sqlite-bundled` and
// `sqlite-unbundled` hand libsqlite3-sys two conflicting build strategies, and
// cargo features are additive, so nothing but a hard error can stop a caller
// enabling both. Failing here beats a confusing libsqlite3-sys build error.

#[cfg(all(feature = "link-static", feature = "link-dynamic"))]
compile_error!(
    "features `link-static` and `link-dynamic` are mutually exclusive - enable exactly one. \
     `link-static` compiles librdkafka and SQLite into the binary; `link-dynamic` links the \
     shared libraries found via pkg-config. This usually means two feature sets were combined, \
     e.g. `full` (static) together with `full-dynamic`; add --no-default-features or pick one."
);

// sqlx has no SQLite driver of its own here: the driver arrives with the
// linkage feature, so `--features sqlx` on its own cannot compile.
#[cfg(all(
    feature = "sqlx",
    not(any(feature = "link-static", feature = "link-dynamic"))
))]
compile_error!(
    "the `sqlx` endpoint (also reached through `postgres-cdc`) needs a linkage feature: add \
     `link-static` to compile SQLite from source, or `link-dynamic` to link a shared \
     libsqlite3 >= 3.34.1 via pkg-config (which also needs libclang for bindgen). The `full`, \
     `full-static-ibm-mq` and `full-dynamic` feature sets already include one."
);

pub mod canonical_message;
#[cfg(any(
    feature = "mongodb",
    feature = "sqlx",
    feature = "clickhouse",
    feature = "object-store"
))]
pub mod checkpoint;
pub mod command_handler;
pub mod endpoints;
pub mod errors;
pub mod event_handler;
pub mod event_store;
pub mod extensions;
pub mod middleware;
pub mod models;
pub mod outcomes;
#[cfg(feature = "plugin")]
pub mod plugin;
pub mod publisher;
pub mod response;
pub mod route;
pub mod support;
#[cfg(feature = "test-utils")]
pub mod test_utils;
pub mod traits;
pub mod type_handler;

pub use anyhow;
pub use canonical_message::{CanonicalMessage, MessageContext};
pub use errors::HandlerError;
pub use models::Route;
pub use outcomes::{Handled, Received, ReceivedBatch, Sent, SentBatch};
pub use publisher::Publisher;

pub use endpoints::memory::get_or_create_channel;
pub use publisher::{get_publisher, list_publishers, register_publisher, unregister_publisher};
pub use route::{
    get_route, list_routes, register_endpoint, route_outcome, route_status, stop_route,
    RouteOutcome,
};

// Re-export the underlying driver crate for each feature-gated endpoint, so
// downstream code can depend on the exact same version mq-bridge builds against
// (and share types with it) without adding — and keeping in sync — its own
// dependency entry. Each is gated on the feature that pulls the crate in.
#[cfg(feature = "nats")]
pub use async_nats;
#[cfg(feature = "amqp")]
pub use lapin;
#[cfg(feature = "mongodb")]
pub use mongodb;
#[cfg(feature = "kafka")]
pub use rdkafka;
#[cfg(feature = "redis-streams")]
pub use redis;
#[cfg(feature = "clickhouse")]
pub use reqwest;
#[cfg(feature = "mqtt")]
pub use rumqttc;
#[cfg(feature = "websocket")]
pub use tokio_websockets;
#[cfg(feature = "zeromq")]
pub use zeromq;
#[cfg(feature = "aws")]
pub use {aws_config, aws_sdk_sns, aws_sdk_sqs};
#[cfg(feature = "grpc")]
pub use {prost, tonic};
// `sqlx` is also enabled transitively by `postgres-cdc`; the integration tests
// use this re-export instead of a duplicate dev-dependency.
#[cfg(any(feature = "ibm-mq", feature = "ibm-mq-static"))]
pub use mqi;
#[cfg(feature = "postgres-cdc")]
pub use pgwire_replication;
#[cfg(feature = "sqlx")]
pub use sqlx;

pub mod consumer {
    pub use crate::middleware::apply_middlewares_to_consumer as apply_middlewares;
}

/// The application name, derived from the package name in Cargo.toml.
pub const APP_NAME: &str = env!("CARGO_PKG_NAME");