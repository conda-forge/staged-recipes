import pyladoc
import pandas as pd


def test_readme_example():
    doc = pyladoc.DocumentWriter()

    doc.add_markdown("""
        # Example
        This is inline LaTeX: $$\\lambda$$

        This is a LaTeX block with a number:
        $$
        \\label{eq:test1}
        \\lambda_{\text{mix}} = \\sum_{i=1}^{n} \\frac{x_i \\lambda_i}{\\sum_{j=1}^{n} x_j \\Phi_{ij}}
        $$

        This is an example table. The table @table:pandas_example shows some random data.
        """)

    some_data = {
        'Row1': ["Line1", "Line2", "Line3"],
        'Row2': [120, 100, 110],
        'Row3': ['12 g/km', '> 150 g/km', '110 g/km']
    }
    df = pd.DataFrame(some_data)
    doc.add_table(df, 'This is a pandas example table', 'pandas_example')

    html_code = doc.to_html()
    print(html_code)

    assert '<table' in html_code
