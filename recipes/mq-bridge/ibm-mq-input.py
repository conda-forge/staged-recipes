"""Consume an IBM MQ queue with the mq-bridge Python bindings.

The IBM MQ endpoint is already compiled into the conda-forge `mq-bridge-py`
package and into upstream's `full` PyPI wheel, so nothing has to be rebuilt.
What it does need is IBM's redistributable MQ client at runtime, found through
MQ_INSTALLATION_PATH (or MQB_IBM_MQ_LIB, or the platform's library search path)
-- see docs/IBM_MQ.md.

    export MQ_INSTALLATION_PATH=/opt/mqm
    export MQ_PASSWORD=...
    python ibm-mq-input.py
"""

import os

import mq_bridge

# 1. Define the route. The endpoint key is `ibmmq` -- one word, no underscore --
#    and `url` is IBM's `host(port)` form rather than a URI scheme. A
#    comma-separated list gives client-side failover. Use `topic` in place of
#    `queue` to subscribe rather than to get from a queue.
route_config = {
    "input": {
        "ibmmq": {
            "url": "mq1.example.com(1414),mq2.example.com(1414)",
            "queue_manager": "QM1",
            "channel": "DEV.APP.SVRCONN",
            "queue": "DEV.QUEUE.1",
            "username": os.environ.get("MQ_USER", "app"),
            "password": os.environ["MQ_PASSWORD"],
        }
    },
    # All the work happens in the handler below, so there is nothing to forward.
    # Replace with {"memory": {"topic": "orders"}} -- or any other endpoint -- to
    # pass the handler's return value on instead of discarding it.
    "output": "null",
}


# 2. The handler runs once per message.
#
#    Returning bytes, a str, a dict or a mq_bridge.Message publishes that to the
#    output endpoint; returning None acknowledges the message without publishing
#    anything. Raise mq_bridge.RetryableError to have the message redelivered,
#    or mq_bridge.NonRetryableError to fail it outright.
def process_message(message):
    payload = message.payload  # bytes, exactly as they arrived on the queue
    print(f"received {len(payload)} bytes, metadata={message.metadata}")

    # message.text() and message.json() decode the payload when the queue
    # carries text or JSON rather than an opaque blob.

    return None


# 3. Attach the handler and deploy. `run()` blocks until `stop()` is called;
#    `start()` deploys on a background thread and returns immediately, with
#    `join()` to wait for it.
route = mq_bridge.Route.from_config(route_config, "orders_from_mq").with_handler(
    process_message
)

if __name__ == "__main__":
    try:
        route.run()
    except KeyboardInterrupt:
        route.stop()
