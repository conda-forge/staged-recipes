# The first example on https://hpr.fusionspace.co/python.html: a 54 mm rocket on a Cesaroni H54
# from the bundled motor catalog, flown from a 1.8 m rail into a 5 m/s wind. No network is used.
from fusionspace import hpr

environment = hpr.Environment(32.99, -106.97, 1400.0, wind_speed_m_s=5.0, wind_from_deg=270.0)

rocket = hpr.Rocket("My 54 mm rocket", 0.0563)
rocket.add_nose("ogive", 0.22, "abs", wall_m=0.0015)
rocket.add_tube(0.9, 0.00115, "kraft_phenolic")
rocket.add_motor_tube(0.2, 0.029, 0.001, "kraft_phenolic", overhang_m=0.005)
rocket.add_fins(
    3,
    root_chord_m=0.1,
    tip_chord_m=0.04,
    span_m=0.045,
    sweep_m=0.05,
    thickness_m=0.003175,
    material="birch_plywood",
    cross_section="rounded",
)
rocket.add_mass(0.2, position="top", offset_m=0.07, name="recovery bay")
rocket.set_motor(hpr.Motor.from_catalog("H54", delay_s=10.0))
rocket.add_parachute("parachute", diameter_m=0.9, trigger="motor_delay")

flight = hpr.Flight(rocket, environment, 1.8, inclination_deg=85.0, heading_deg=270.0)
print(f"Apogee: {flight.apogee_m:.1f} m at {flight.apogee_time_s:.2f} s")

# The documentation prints 1118.3 m; the project's own release checks accept it within a meter.
assert abs(flight.apogee_m - 1118.3) < 1.0, flight.apogee_m
