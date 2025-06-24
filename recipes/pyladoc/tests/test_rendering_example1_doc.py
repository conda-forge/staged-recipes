import pyladoc
import matplotlib.pyplot as plt
import pandas as pd
from . import document_validation
import numpy as np

VALIDATE_HTML_CODE_ONLINE = True
WRITE_RESULT_FILES = False


def mason_saxena_k_mixture(x_h2):
    """
    Calculate the thermal conductivity of a H2/CO2 gas mixture using the Mason and Saxena mixing rule.

    The mixture thermal conductivity is computed as:
        k_mix = Σ_i [ X_i * k_i / (Σ_j X_j * φ_ij) ]
    with:
        φ_ij = 1/√8 * (1 + M_i/M_j)^(-0.5) * [ 1 + ( (k_i/k_j)**0.5 * (M_j/M_i)**0.25 ) ]^2

    Parameters:
        x_h2 (float or array-like): Mole fraction of H2 (from 0 to 1). The CO2 mole fraction is 1 - x_h2.

    Returns:
        float or array-like: Thermal conductivity of the mixture in W/m·K.
    """
    # Pure gas properties (at room temperature, approx.)
    k_h2 = 0.1805   # Thermal conductivity of H2 in W/mK
    k_co2 = 0.0166  # Thermal conductivity of CO2 in W/mK

    M_h2 = 2.016    # Molar mass of H2 in g/mol
    M_co2 = 44.01   # Molar mass of CO2 in g/mol

    # Define the phi_ij function according to Mason and Saxena.
    def phi(k_i, k_j, M_i, M_j):
        return (1 / np.sqrt(8)) * (1 + M_i / M_j) ** (-0.5) * (1 + ((k_i / k_j) ** 0.5 * (M_j / M_i) ** 0.25))**2

    # Compute phi terms for the two species.
    # For i = j the phi terms should be 1.
    phi_h2_h2 = phi(k_h2, k_h2, M_h2, M_h2)       # Should be 1
    phi_h2_co2 = phi(k_h2, k_co2, M_h2, M_co2)
    phi_co2_h2 = phi(k_co2, k_h2, M_co2, M_h2)
    phi_co2_co2 = phi(k_co2, k_co2, M_co2, M_co2)   # Should be 1

    # Ensure we can perform vectorized operations.
    x_h2 = np.array(x_h2)
    x_co2 = 1 - x_h2

    # Use the Mason-Saxena mixing rule:
    # k_mix = X_H2 * k_H2 / (X_H2*φ_H2_H2 + X_CO2*φ_H2_CO2) +
    #         X_CO2 * k_CO2 / (X_CO2*φ_CO2_CO2 + X_H2*φ_CO2_H2)
    k_mix = (x_h2 * k_h2 / (x_h2 * phi_h2_h2 + x_co2 * phi_h2_co2)) + \
            (x_co2 * k_co2 / (x_co2 * phi_co2_co2 + x_h2 * phi_co2_h2))

    return k_mix


def make_document():
    doc = pyladoc.DocumentWriter()

    doc.add_markdown("""
    # Thermal Conductivity of Mixtures

    The determination of the thermal conductivity of gas mixtures is a central aspect of modeling
    transport phenomena, particularly in high-temperature and high-pressure processes. Among the
    most established approaches is the empirical equation introduced by Wassiljewa, which was
    subsequently refined by Mason and Saxena to improve its applicability to multicomponent systems.
    This model offers a reliable means of estimating the thermal conductivity of gas mixtures based
    on the properties of the pure components and their molar interactions.

    The thermal conductivity of a gas mixture, denoted by $$\\lambda_{\\text{mix}}$$, can expressed as
    shown in equation @eq:lambda_mixture.

    $$
    \\label{eq:lambda_mixture}
    \\lambda_{\text{mix}} = \\sum_{i=1}^{n} \\frac{x_i \\lambda_i}{\\sum_{j=1}^{n} x_j \\Phi_{ij}}
    $$

    In this equation, $$x_i$$ represents the molar fraction of component $$i$$ within the mixture,
    while $$\\lambda_i$$ denotes the thermal conductivity of the pure substance $$i$$. The denominator
    contains the interaction parameter $$\\Phi_{ij}$$, which describes the influence of component
    $$j$$ on the transport properties of component $$i$$.

    The interaction parameter $$\\Phi_{ij}$$ is given by the relation shown in equation @eq:interaction_parameter.

    $$
    \\label{eq:interaction_parameter}
    \\Phi_{ij} = \\frac{1}{\\sqrt{8}} \\left(1 + \\frac{M_i}{M_j} \\right)^{-1/2} \\left[ 1 + \\left( \\frac{\\lambda_i}{\\lambda_j} \\right)^{1/2} \\left( \\frac{M_j}{M_i} \\right)^{1/4} \\right]^2
    $$

    Here, $$M_i$$ and $$M_j$$ are the molar masses of the components $$i$$ and $$j$$, respectively.
    Molar masses and thermal conductivity of the pure substances are listed in table @table:gas_probs.
    The structure of this expression illustrates the nonlinear dependence of the interaction term on
    both the molar mass ratio and the square root of the conductivity ratio of the involved species.
    """)

    # Table
    data = {
        "Gas": ["H2", "O2", "N2", "CO2", "CH4", "Ar", "He"],
        "Molar mass in g/mol": ["2.016", "32.00", "28.02", "44.01", "16.04", "39.95", "4.0026"],
        "Thermal conductivity in W/m/K": ["0.1805", "0.0263", "0.0258", "0.0166", "0.0341", "0.0177", "0.1513"]
    }
    df = pd.DataFrame(data)
    doc.add_table(df.style.hide(axis="index"), 'Properties of some gases', 'gas_probs')

    doc.add_markdown("""
    This formulation acknowledges that the transport properties of a gas mixture are not a simple
    linear combination of the individual conductivities. Rather, they are governed by intermolecular
    interactions, which affect the energy exchange and diffusion behavior of each component. These
    interactions are particularly significant at elevated pressures or in cases where the gas components
    exhibit widely differing molecular masses or transport properties.

    The equation proposed by Wassiljewa and refined by Mason and Saxena assumes that binary interactions
    dominate the behavior of the mixture, while higher-order (three-body or more) interactions are
    neglected. It also presumes that the gases approximate ideal behavior, although in practical
    applications, moderate deviations from ideality are tolerated without significant loss of accuracy.
    In figure @fig:mixture the resulting thermal conductivity of an H2/CO2-mixture is shown.""")

    # Figure
    x_h2_values = np.linspace(0, 1, 100)
    k_mixture_values = mason_saxena_k_mixture(x_h2_values)

    fig, ax = plt.subplots()
    ax.set_xlabel("H2 molar fraction / %")
    ax.set_ylabel("Thermal Conductivity / (W/m·K)")
    ax.plot(x_h2_values * 100, k_mixture_values, color='black')

    doc.add_diagram(fig, 'Thermal Conductivity of H2/CO2 mixtures', 'mixture')

    doc.add_markdown("""
    In engineering practice, the accurate determination of $$\\lambda_{\\text{mix}}$$ is essential
    for the prediction of heat transfer in systems such as membrane modules, chemical reactors, and
    combustion chambers. In the context of membrane-based gas separation, for instance, the thermal
    conductivity of the gas mixture influences the local temperature distribution, which in turn affects
    both the permeation behavior and the structural stability of the membrane.

    It is important to note that the calculated mixture conductivity reflects only the gas phase
    behavior. In porous systems such as carbon membranes, additional effects must be considered.
    These include the solid-phase thermal conduction through the membrane matrix, radiative transport
    in pore channels at high temperatures, and transport in the Knudsen regime for narrow pores.
    To account for these complexities, models based on effective medium theory, such as those of
    Maxwell-Eucken or Bruggeman, are frequently employed. These models combine the conductivities of
    individual phases (gas and solid) with geometrical factors that reflect the morphology of the
    porous structure.

    ---

    Expanded by more or less sensible AI jabbering; based on: [doi:10.14279/depositonce-7390](https://doi.org/10.14279/depositonce-7390)
    """)

    return doc


def test_html_render():
    doc = make_document()
    html_code = doc.to_html()

    document_validation.validate_html(html_code, VALIDATE_HTML_CODE_ONLINE)

    if WRITE_RESULT_FILES:
        with open('tests/out/test_html_render1.html', 'w', encoding='utf-8') as f:
            f.write(pyladoc.inject_to_template({'CONTENT': html_code}, internal_template='templates/test_template.html'))


def test_latex_render():
    doc = make_document()

    if WRITE_RESULT_FILES:
        with open('tests/out/test_html_render1.tex', 'w', encoding='utf-8') as f:
            f.write(doc.to_latex())

        assert doc.to_pdf('tests/out/test_latex_render1.pdf', font_family='serif')
    else:
        assert doc.to_pdf('', font_family='serif')  # Write only to temp folder


if __name__ == '__main__':
    test_html_render()
    test_latex_render()
