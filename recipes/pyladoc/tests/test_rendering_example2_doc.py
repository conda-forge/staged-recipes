import pyladoc
import matplotlib.pyplot as plt
import pandas as pd
from . import document_validation

VALIDATE_HTML_CODE_ONLINE = False
WRITE_RESULT_FILES = False


def make_document():
    doc = pyladoc.DocumentWriter()

    doc.add_markdown("""
    # Special characters

    ö ä ü Ö Ä Ü ß @ ∆

    π ≈ ± ∆ Σ

    £ ¥ $ €

    Œ

    # Link

    This is a hyperlink: [nonan.net](https://www.nonan.net)

    # Table

    | Anz.| Typ      | Beschreibung
    |----:|----------|------------------------------------
    | 12  | BK9050   | Buskoppler
    |  2  | KL1104   | 4 Digitaleingänge
    |  2  | KL2404   | 4 Digitalausgänge (0,5 A)
    |  3  | KL2424   | 4 Digitalausgänge (2 A)
    |  2  | KL4004   | 4 Analogausgänge
    |  1  | KL4002   | 2 Analogausgänge
    | 22  | KL9188   | Potenzialverteilungsklemme
    |  1  | KL9100   | Potenzialeinspeiseklemme
    |  3  | KL3054   | 4 Analogeingänge
    |  5  | KL3214   | PT100 4 Temperatureingänge (3-Leiter)
    |  3  | KL3202   | PT100 2 Temperatureingänge (3-Leiter)
    |  1  | KL2404   | 4 Digitalausgänge
    |  2  | KL9010   | Endklemme

    ---

    # Equations

    This line represents a reference to the equation @eq:test1.
    """)

    doc.add_equation(r'y = a + b * \sum_{i=0}^{\infty} a_i x^i', 'test1')

    # Figure
    fig, ax = plt.subplots()

    fruits = ['apple', 'blueberry', 'cherry', 'orange']
    counts = [40, 100, 30, 55]
    bar_labels = ['red', 'blue', '_red', 'orange']
    bar_colors = ['tab:red', 'tab:blue', 'tab:red', 'tab:orange']

    ax.bar(fruits, counts, label=bar_labels, color=bar_colors)
    ax.set_ylabel('fruit supply')
    ax.set_title('Fruit supply by kind and color')
    ax.legend(title='Fruit color')

    doc.add_diagram(fig, 'Bar chart with individual bar colors')

    # Table
    mydataset = {
        'Row1': ["Line1", "Line2", "Line3", "Line4", "Line5"],
        'Row2': [120, '95 km/h', 110, '105 km/h', 130],
        'Row3': ['12 g/km', '> 150 g/km', '110 g/km', '1140 g/km', '13.05 g/km'],
        'Row4': ['5 stars', '4 stars', '5 stars', '4.5 stars', '5 stars'],
        'Row5': [3.5, 7.8, 8.5, 6.9, 4.2],
        'Row6': ['1850 kg', '1500 kg', '1400 kg', '1600 kg', '1700 kg'],
        'Row7': ['600 Nm', '250 Nm', '280 Nm', '320 Nm', '450 Nm']
    }
    df = pd.DataFrame(mydataset)

    doc.add_table(df.style.hide(axis="index"), 'This is a example table', 'example1')

    return doc


def test_html_render():
    doc = make_document()
    html_code = doc.to_html()

    document_validation.validate_html(html_code, VALIDATE_HTML_CODE_ONLINE)

    if WRITE_RESULT_FILES:
        with open('tests/out/test_html_render2.html', 'w', encoding='utf-8') as f:
            f.write(pyladoc.inject_to_template(html_code, internal_template='templates/test_template.html'))


def test_latex_render():
    doc = make_document()

    if WRITE_RESULT_FILES:
        with open('tests/out/test_html_render2.tex', 'w', encoding='utf-8') as f:
            f.write(doc.to_latex())

    assert doc.to_pdf('tests/out/test_latex_render2.pdf', font_family='serif')


if __name__ == '__main__':
    test_html_render()
    test_latex_render()
