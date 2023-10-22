#!/usr/bin/env python

"""Tests for `commlib` package."""

import time
import unittest
from typing import Optional

from commlib.msg import MessageHeader, PubSubMessage, RPCMessage
from commlib.node import Node, TransportType
from commlib.transports.mock import ConnectionParameters


class SonarMessage(PubSubMessage):
    header: MessageHeader = MessageHeader()
    range: float = -1
    hfov: float = 30.6
    vfov: float = 14.2


class AddTwoIntMessage(RPCMessage):
    class Request(RPCMessage.Request):
        a: int = 0
        b: int = 0

    class Response(RPCMessage.Response):
        c: int = 0


class TestNode(unittest.TestCase):
    """Tests for `commlib` package."""

    def setUp(self):
        """Set up test fixtures, if any."""
        self.connparams = ConnectionParameters(host='test', port='1234')

    def tearDown(self):
        """Tear down test fixtures, if any."""

    def test_node_create_wrong_transport(self):
        try:
            node = Node(node_name='sensors.sonar.front',
                        connection_params=self.connparams)
            self.assertTrue(1, 0)
        except ValueError as e:
            print(str(e))
            if str(e) == 'ValueError: Transport type is not supported!':
                self.assertTrue(1, 1)
            else:
                self.assertTrue(1, 0)

    def test_node_create_publisher(self):
        node = Node(node_name='sensors.sonar.front',
                    connection_params=self.connparams)
        node.create_publisher(msg_type=SonarMessage,
                              topic='sensors.sonar.front')
        self.assertTrue(len(node._publishers), 1)
