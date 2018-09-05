"""Runs the basic tests for pycoalescence imports"""
import os
import unittest
import shutil

class TestImports(unittest.TestCase):
	"""Tests module imports are successful"""

	def testImportModule(self):
		"""Tests that the whole module can be imported"""
		try:
			import pycoalescence
		except ImportError as ie:
			self.fail("Cannot import pycoalescence: {}".format(ie))

	def testImportMain(self):
		"""Tests that the main pycoalescence objects can be imported and are not NoneType."""
		try:
			from pycoalescence import Simulation, CoalescenceTree, DispersalSimulation
			for each in ["Simulation", "CoalescenceTree", "DispersalSimulation"]:
				if eval(each) is None:
					raise ImportError("{} is None.".format(each))
		except ImportError as ie:
			self.fail("Cannot import main pycoalescence objects: {}".format(ie))

	def testImportNecsim(self):
		"""Tests that necsim imports correctly."""
		try:
			from pycoalescence.necsim import libnecsim
			if libnecsim is None:
				raise ImportError("libnecsim is None.")
		except ImportError as ie:
			self.fail("Cannot import c++ libnecsim module: {}".format(ie))

class TestBasicSimulation(unittest.TestCase):
	"""Tests that a very basic simulation can be performed. """
	@classmethod
	def setUpClass(cls):
		"""Runs a very basic simulation."""
		from pycoalescence import Simulation
		cls.sim = Simulation(logging_level=50)
		cls.sim.set_simulation_parameters(seed=1, job_type=2, output_directory="tmp", min_speciation_rate=0.9)
		cls.sim.set_map("null", 10, 10)
		cls.sim.run()

	@classmethod
	def tearDownClass(cls):
		"""Removes the tmp directory."""
		if os.path.exists('tmp'):
			try:
				shutil.rmtree("tmp")
			except OSError:
				pass

	def testOutputExists(self):
		"""Tests that a simulation output database exists at the correct directory."""
		if not os.path.exists(os.path.join("tmp", "data_2_1.db")):
			self.fail("Output database not created.")


if __name__ == "__main__":
	unittest.main()