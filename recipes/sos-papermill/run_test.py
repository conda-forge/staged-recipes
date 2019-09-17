#!/usr/bin/env python3
#
# Copyright (c) Bo Peng and the University of Texas MD Anderson Cancer Center
# Distributed under the terms of the 3-clause BSD License.
#
import abc
import os
import unittest
from nbformat.notebooknode import NotebookNode
from mock import Mock, patch

from papermill import engines
from papermill.log import logger
from papermill.iorw import load_notebook_node
from papermill.engines import NotebookExecutionManager, Engine

from sos_papermill.engine import SoSExecutorEngine

def get_notebook_path(*args):
    return os.path.join(os.path.dirname(os.path.abspath(__file__)), 'notebooks', *args)

def get_notebook_dir(*args):
    return os.path.dirname(get_notebook_path(*args))

ABC = abc.ABCMeta('ABC', (object,), {'__slots__': ()})

def AnyMock(cls):
    """
    Mocks a matcher for any instance of class cls.
    e.g. my_mock.called_once_with(Any(int), "bar")
    """

    class AnyMock(ABC):
        def __eq__(self, other):
            return isinstance(other, cls)

    AnyMock.register(cls)
    return AnyMock()

class TestSoSExecutorEngine(unittest.TestCase):
    def setUp(self):
        self.notebook_name = 'sos_python3.ipynb'
        self.notebook_path = get_notebook_path(self.notebook_name)
        self.nb = load_notebook_node(self.notebook_path)
        self.nb.metadata.papermill['input_path'] = 'sos_python3.ipynb'

    def test_sos_executor_engine_execute(self):
        with patch.object(NotebookExecutionManager, 'save') as save_mock:
            nb = SoSExecutorEngine.execute_notebook(
                self.nb, 'sos', output_path='foo.ipynb', progress_bar=False, log_output=True
            )
            #self.assertEqual(save_mock.call_count, 8)
            self.assertEqual(nb, AnyMock(NotebookNode))

            self.assertIsNotNone(nb.metadata.papermill['start_time'])
            self.assertIsNotNone(nb.metadata.papermill['end_time'])
            self.assertEqual(nb.metadata.papermill['duration'], AnyMock(float))
            self.assertFalse(nb.metadata.papermill['exception'])

            for cell in nb.cells:
                self.assertIsNotNone(cell.metadata.papermill['start_time'])
                self.assertIsNotNone(cell.metadata.papermill['end_time'])
                self.assertEqual(cell.metadata.papermill['duration'], AnyMock(float))
                self.assertFalse(cell.metadata.papermill['exception'])
                self.assertEqual(
                    cell.metadata.papermill['status'], NotebookExecutionManager.COMPLETED
                )
