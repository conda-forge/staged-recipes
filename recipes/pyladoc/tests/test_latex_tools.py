import pyladoc.latex


def normalize_latex_code(latex_code: str) -> str:
    return '\n'.join(line.strip() for line in latex_code.splitlines() if line)


def check_only_ascii(latex_code: str) -> bool:
    return all(ord(c) < 128 for c in latex_code)


def test_latex_from_html():
    html_code = """
    <h1>Test</h1>
    <p>This is are Umlautes: Ä,Ö and Ü</p>
    <p>This is a <b>test</b>.</p>
    <p>And this is another <em>test</em>.</p>
    <p>And this is a <strong>third</strong> test.</p>
    <p>And this is a <i>fourth</i> test.</p>
    <p>This is a LaTeX command: \\textbf{test}</p>
    <p>This are typical control characters: {, }, <, >, ", ', &, |, /, \\</p>
    <ul>
        <li>Item 1</li>
        <li>Item 2</li>
    </ul>
    <table>
        <tr>
            <th>Header 1</th>
            <th>Header 2</th>
        </tr>
        <tr>
            <td>Cell 1</td>
            <td>Cell 2</td>
        </tr>
    </table>
    """

    latex_code = pyladoc.latex.from_html(html_code)

    ref_latex_code = r"""
        \section{Test}
        This is are Umlautes: {\"A},{\"O} and {\"U}
        This is a \textbf{test}.
        And this is another \emph{test}.
        And this is a \textbf{third} test.
        And this is a \emph{fourth} test.
        This is a LaTeX command: \textbackslash{}textbf\{test\}
        This are typical control characters: \{, \}, {\textless}, {\textgreater}, ", ', \&, |, /, \textbackslash{}
        \begin{itemize}
        \item Item 1
        \item Item 2
        \end{itemize}
        \begin{tabular}{ll}\toprule
        Header 1 & Header 2 \\
        \midrule
        Cell 1 & Cell 2 \\
        \bottomrule
        \end{tabular}"""

    print(latex_code)

    print('--')

    # print(pyladoc.latex.escape_text(html_code))

    assert check_only_ascii(latex_code), 'Some characters are not ASCII'
    assert normalize_latex_code(ref_latex_code) == normalize_latex_code(latex_code)


def test_latex_from_markdown():
    markdown_code = """
        ## Test1

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

        This is a **test**.

        ## Test2

        | Anz.| Beschreibung
        |----:|------------------------------------
        | 12  | Buskoppler
        |  2  | 4 Digitaleingänge
        |  2  | 4 Digitalausgänge (0,5 A)
        |  3  | 4 Digitalausgänge (2 A)
        |  2  | 4 Analogausgänge
        |  1  | 2 Analogausgänge
    """

    pyla = pyladoc.DocumentWriter()
    pyla.add_markdown(markdown_code)
    latex_code = pyladoc.latex.from_html(pyla.to_html())

    ref_latex_code = r"""
        \subsection{Test1}
        \begin{tabular}{rll}\toprule
        Anz. & Typ & Beschreibung \\
        \midrule
        12 & BK9050 & Buskoppler \\
        2 & KL1104 & 4 Digitaleing{\"a}nge \\
        2 & KL2404 & 4 Digitalausg{\"a}nge (0,5 A) \\
        3 & KL2424 & 4 Digitalausg{\"a}nge (2 A) \\
        2 & KL4004 & 4 Analogausg{\"a}nge \\
        1 & KL4002 & 2 Analogausg{\"a}nge \\
        22 & KL9188 & Potenzialverteilungsklemme \\
        1 & KL9100 & Potenzialeinspeiseklemme \\
        3 & KL3054 & 4 Analogeing{\"a}nge \\
        5 & KL3214 & PT100 4 Temperatureing{\"a}nge (3-Leiter) \\
        3 & KL3202 & PT100 2 Temperatureing{\"a}nge (3-Leiter) \\
        1 & KL2404 & 4 Digitalausg{\"a}nge \\
        2 & KL9010 & Endklemme \\
        \bottomrule
        \end{tabular}
        This is a \textbf{test}.

        \subsection{Test2}
        \begin{tabular}{rl}\toprule
        Anz. & Beschreibung \\
        \midrule
        12 & Buskoppler \\
        2 & 4 Digitaleing{\"a}nge \\
        2 & 4 Digitalausg{\"a}nge (0,5 A) \\
        3 & 4 Digitalausg{\"a}nge (2 A) \\
        2 & 4 Analogausg{\"a}nge \\
        1 & 2 Analogausg{\"a}nge \\
        \bottomrule
        \end{tabular}"""

    print(latex_code)

    assert check_only_ascii(latex_code), 'Some characters are not ASCII'
    assert normalize_latex_code(ref_latex_code) == normalize_latex_code(latex_code)


if __name__ == '__main__':
    test_latex_from_html()
    test_latex_from_markdown()
