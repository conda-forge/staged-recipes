import pyladoc


def test_latex_embedding2():
    test_input = pyladoc._normalize_text_indent("""
    In this equation, $$x_i$$ represents the molar fraction of component $$i$$ within the mixture,
    while $$\\lambda_i$$ denotes the thermal conductivity of the pure substance $$i$$. The denominator
    contains the interaction parameter $$\\Phi_{ij}$$, which describes the influence of component
    $$j$$ on the transport properties of component $$i$$.

    The interaction parameter $$\\Phi_{ij}$$ is given by the relation shown in @eq:ExampleFormula2.

    $$
    \\label{eq:ExampleFormula2}
    \\Phi_{ij} = \\frac{1}{\\sqrt{8}} \\left(1 + \\frac{M_i}{M_j} \\right)^{-1/2} \\left[ 1 + \\left( \\frac{\\lambda_i}{\\lambda_j} \\right)^{1/2} \\left( \\frac{M_j}{M_i} \\right)^{1/4} \\right]^2
    $$
    """)

    expected_output = pyladoc._normalize_text_indent(r"""
    In this equation, <latex>x_i</latex> represents the molar fraction of component <latex>i</latex> within the mixture,
    while <latex>\lambda_i</latex> denotes the thermal conductivity of the pure substance <latex>i</latex>. The denominator
    contains the interaction parameter <latex>\Phi_{ij}</latex>, which describes the influence of component
    <latex>j</latex> on the transport properties of component <latex>i</latex>.

    The interaction parameter <latex>\Phi_{ij}</latex> is given by the relation shown in @eq:ExampleFormula2.<latex type="block" reference="eq:ExampleFormula2" caption="(1)">\Phi_{ij} = \frac{1}{\sqrt{8}} \left(1 + \frac{M_i}{M_j} \right)^{-1/2} \left[ 1 + \left( \frac{\lambda_i}{\lambda_j} \right)^{1/2} \left( \frac{M_j}{M_i} \right)^{1/4} \right]^2</latex>""")

    dummy = pyladoc.DocumentWriter()
    result_string = dummy._equation_embedding_reescaping(test_input)

    print(result_string)
    assert result_string == expected_output


def test_latex_embedding():
    test_input = pyladoc._normalize_text_indent(r"""
    # Test
    $$
    \label{eq:ExampleFormula2}
    \Phi_{ij} = \frac{1}{\sqrt{8}}
    $$
    This $$i$$ is inline LaTeX.
    """)

    expected_output = pyladoc._normalize_text_indent(r"""
    # Test<latex type="block" reference="eq:ExampleFormula2" caption="(1)">\Phi_{ij} = \frac{1}{\sqrt{8}}</latex>This <latex>i</latex> is inline LaTeX.
    """)

    dummy = pyladoc.DocumentWriter()
    result_string = dummy._equation_embedding_reescaping(test_input)

    print(result_string)
    assert result_string == expected_output

    final_html = dummy._html_post_processing(pyladoc._markdown_to_html(result_string))
    print('-- final_html --')
    print(final_html)

    assert '<h1>' in final_html and '<svg ' in final_html and '<div class="equation-number">' in final_html
