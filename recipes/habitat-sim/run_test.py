import numpy as np

import habitat_sim
from habitat_sim.bindings import ConfigStoredType, Configuration as CoreConfiguration

sim_cfg = habitat_sim.SimulatorConfiguration()
agent_cfg = habitat_sim.AgentConfiguration()
agent_cfg.sensor_specifications = []

habitat_sim.Configuration(sim_cfg, [agent_cfg])

sim_cfg.scene_id = "NONE"
with habitat_sim.Simulator(habitat_sim.Configuration(sim_cfg, [agent_cfg])) as sim:
    sim.initialize_agent(0)
    assert sim.get_stage_initialization_template() is None

config = CoreConfiguration()
config.set("recipe_smoke", "habitat-sim")
assert config.has_key_to_type("recipe_smoke", ConfigStoredType.String)
assert config.get("recipe_smoke") == "habitat-sim"

vector = np.array([1.0, 2.0, 3.0], dtype=np.float32)
config.set("vector", vector)
assert config.has_key_to_type("vector", ConfigStoredType.MagnumVec3)
np.testing.assert_allclose(config.get("vector"), vector)
