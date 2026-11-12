"""Smoke-test in-process publish/subscribe with the installed Zenoh bindings."""

from importlib.metadata import version
from queue import Queue

import zenoh


def main():
    assert version("eclipse-zenoh")

    # Keep the session local by disabling endpoints and discovery.
    config = zenoh.Config()
    config.insert_json5("listen/endpoints", "[]")
    config.insert_json5("connect/endpoints", "[]")
    config.insert_json5("scouting/multicast/enabled", "false")
    config.insert_json5("scouting/gossip/enabled", "false")

    received = Queue()
    key = "conda-forge/eclipse-zenoh/test"

    def on_sample(sample):
        received.put(sample.payload.to_bytes())

    with zenoh.open(config) as session:
        with session.declare_subscriber(key, on_sample):
            session.put(key, b"zenoh")
            assert received.get(timeout=5) == b"zenoh"


if __name__ == "__main__":
    main()
