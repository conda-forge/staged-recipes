import numpy as np

import habitat_sim
from habitat_sim.bindings import ConfigValType, Configuration as CoreConfiguration

sim_cfg = habitat_sim.SimulatorConfiguration()
agent_cfg = habitat_sim.AgentConfiguration()
agent_cfg.sensor_specifications = []

cfg = habitat_sim.Configuration(sim_cfg, [agent_cfg])
assert cfg.sim_cfg is sim_cfg
assert cfg.agents == [agent_cfg]

config = CoreConfiguration()
config.set("recipe_smoke", "habitat-sim")
assert config.has_key_to_type("recipe_smoke", ConfigValType.String)
assert config.get("recipe_smoke") == "habitat-sim"

vector = np.array([1.0, 2.0, 3.0], dtype=np.float32)
config.set("vector", vector)
assert config.has_key_to_type("vector", ConfigValType.MagnumVec3)
np.testing.assert_allclose(config.get("vector"), vector)
