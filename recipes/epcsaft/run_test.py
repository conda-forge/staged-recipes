import epcsaft
from epcsaft import equilibrium as eq

# Gross and Sadowski (2001), DOI 10.1021/ie0003887, Table 2.
# Project-authored transcription; k_ij = 0 and neutral/nonassociating choices
# are separate declarations for this example, not additional fitted values.
published = {
    "source_id": "gross-sadowski-2001",
    "citation": "Gross and Sadowski (2001), Table 2",
    "doi": "10.1021/ie0003887",
}
declaration = {
    "source_id": "example-declaration",
    "citation": "Declared neutral nonassociating methane/ethane example with k_ij = 0",
}
provenance = {
    "source_id": published["source_id"],
    "locator": "Table 2",
    "domain_id": "example",
}
chosen = {
    "source_id": declaration["source_id"],
    "locator": "Example declaration",
    "domain_id": "example",
}


def value(magnitude, unit, source):
    return {"value": {"magnitude": magnitude, "unit": unit}, "provenance": source}


components = []
for name, mass, m, sigma, epsilon in (
    ("methane", 0.016043, 1.0, 3.7039, 150.03),
    ("ethane", 0.03007, 1.6069, 3.5206, 191.42),
):
    components.append(
        {
            "component_id": name,
            "fixed": {
                "molar_mass": value(mass, "kg / mol", provenance),
                "charge_number": value(0, "elementary-charge", chosen),
            },
            "coefficients": [
                {
                    "identity": f"component/{name}/{family}",
                    "family": family,
                    **value(number, unit, provenance),
                }
                for family, number, unit in (
                    ("segment_count", m, "dimensionless"),
                    ("segment_diameter", sigma, "angstrom"),
                    ("dispersion_energy_over_k", epsilon, "kelvin"),
                )
            ],
        }
    )
parameters = epcsaft.Parameters.from_mapping(
    {
        "schema": "epcsaft.parameters",
        "schema_version": 1,
        "document_id": "gross-sadowski-2001-conda-example",
        "document_version": 1,
        "purpose": "external-document",
        "sources": [published, declaration],
        "domains": [{"domain_id": "example", "kind": "unknown"}],
        "components": components,
        "pairs": [
            {
                "component_id_a": "methane",
                "component_id_b": "ethane",
                "coefficients": [
                    {
                        "identity": "pair/methane/ethane/k_ij",
                        "family": "k_ij",
                        **value(0.0, "dimensionless", chosen),
                    }
                ],
            }
        ],
        "model_families": [
            {
                "family_id": f"model/{kind}",
                "kind": kind,
                "choice": choice,
                "provenance": chosen,
            }
            for kind, choice in (
                ("base", "pc-saft"),
                ("association", "none"),
                ("electrolyte", "none"),
                ("permittivity", "none"),
            )
        ],
        "model_coefficients": [],
        "correlations": [],
        "topology": {"presets": [], "sites": [], "edges": []},
    },
    components=["methane", "ethane"],
)
mix = epcsaft.Mixture(parameters)
feed = eq.MoleFractions({"methane": 0.3, "ethane": 0.7})
problem = eq.bubble_point(liquid=eq.Phase("L", kind="liquid"), T=200.0, feed=feed)
bubble = eq.solve_equilibrium(mix, problem)  # pressure is free
print(bubble.pressure, bubble.phase_mole_fractions(1))  # Pa; incipient vapor

dT = eq.SolvedStateActionDirection(
    1.0, 0.0, [0.0, 0.0], []
)  # unit temperature direction
P = eq.SolvedStateObservable(eq.SolvedStateObservableKind.Pressure)
batch = eq.solved_state_actions(
    eq.compile_problem(mix, problem), bubble, eq.SolvedStateActionRequest([P], [dT])
)
print(batch.results[0].action, batch.results[0].status)  # Pa/K

import json, math

assert bubble.success, bubble.message
assert bubble.requested_tolerance_met
assert epcsaft._core.linear_solver() == "mumps"
assert batch.results[0].status == eq.SolvedStateActionStatus.Available
assert (
    bubble.pressure is not None
    and math.isfinite(bubble.pressure)
    and bubble.pressure > 0.0
)
assert math.isfinite(batch.results[0].action) and batch.results[0].action > 0.0
vapor = bubble.phase_mole_fractions(1)
assert math.isclose(sum(vapor), 1.0, abs_tol=1e-10)
assert all(0.0 <= x <= 1.0 for x in vapor)
print(
    json.dumps(
        {
            "pressure_Pa": bubble.pressure,
            "vapor_mole_fractions": vapor,
            "temperature_action_Pa_per_K": batch.results[0].action,
            "central_max_abs_residual": max(map(abs, bubble.residuals)),
            "action_central_residual": batch.diagnostics.central_residual,
            "action_maximum_linear_residual": batch.diagnostics.maximum_linear_residual,
            "linear_solver": epcsaft._core.linear_solver(),
            "package_path": epcsaft.__file__,
        },
        indent=2,
    )
)

assert math.isclose(bubble.pressure, 1695742.8953910777, rel_tol=1e-8)
assert math.isclose(vapor[0], 0.8673216367151354, rel_tol=0.0, abs_tol=1e-9)
assert math.isclose(vapor[1], 0.13267836328486465, rel_tol=0.0, abs_tol=1e-9)
assert math.isclose(batch.results[0].action, 39302.24177938897, rel_tol=1e-8)
assert max(map(abs, bubble.residuals)) <= 1e-10
assert batch.diagnostics.maximum_linear_residual <= 1e-10
