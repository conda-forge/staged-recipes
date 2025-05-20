import pyladoc
from . import document_validation

VALIDATE_HTML_CODE_ONLINE = False
WRITE_RESULT_FILES = True


def test_markdown_styling():
    pyla = pyladoc.DocumentWriter()
    pyla.add_markdown(
        """
        Below is an in-depth explanation of the AArch64 (ARM64)
        unconditional branch instruction—often simply called the
        “B” instruction—and how its 26‐bit immediate field (imm26)
        is laid out and later relocated during linking.

        ---

        ## Instruction Layout

        The unconditional branch in AArch64 is encoded in a 32‑bit
        instruction. Its layout is as follows:

        ```
        Bits:  31         26 25                           0
                +-------------+------------------------------+
                |  Opcode     |          imm26               |
                +-------------+------------------------------+
        ```

        - **Opcode (bits 31:26):**
        - For a plain branch (`B`), the opcode is `000101`.
        - For a branch with link (`BL`), which saves the return
        address (i.e., a call), the opcode is `100101`.
        These 6 bits determine the instruction type.

        - **Immediate Field (imm26, bits 25:0):**
        - This 26‑bit field holds a signed immediate value.
        - **Offset Calculation:** At runtime, the processor:
            1. **Shifts** the 26‑bit immediate left by 2 bits.
            (Because instructions are 4-byte aligned,
            the two least-significant bits are always zero.)
            2. **Sign-extends** the resulting 28‑bit value to
            the full register width (typically 64 bits).
            3. **Adds** this value to the program counter
            (PC) to obtain the branch target.

        - **Reach:**
        - With a 26‑bit signed field that’s effectively 28 bits
          after the shift, the branch can cover a range
          of approximately ±128 MB from the current instruction.
        """)

    html_code = pyla.to_html()
    document_validation.validate_html(html_code, check_for=['strong', 'ol', 'li', 'code', 'hr'])

    if WRITE_RESULT_FILES:
        with open('tests/out/test_markdown_style.html', 'w', encoding='utf-8') as f:
            f.write(html_code)


def test_markdown_table():
    pyla = pyladoc.DocumentWriter()
    pyla.add_markdown(
        """
        ## Klemmen

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
        """)

    html_code = pyla.to_html()
    document_validation.validate_html(html_code, check_for=['table'])

    if WRITE_RESULT_FILES:
        with open('tests/out/test_markdown_table.html', 'w', encoding='utf-8') as f:
            f.write(html_code)


def test_markdown_equations():
    pyla = pyladoc.DocumentWriter()
    pyla.add_markdown(
        """
        # Source Equations
        1. $4(3x + 2) - 5(x - 1) = 3x + 14$
        2. $\frac{2y + 5}{4} + \frac{3y - 1}{2} = 5$
        3. $\frac{5}{x + 2} + \frac{2}{x - 2} = 3$
        4. $8(3b - 5) + 4(b + 2) = 60$
        5. $2c^2 - 3c - 5 = 0$
        6. $4(2d - 1) + 5(3d + 2) = 7d + 28$
        7. $q^2 + 6q + 9 = 16$

        # Result Equations
        1. $x = \frac{1}{4}$
        2. $y = \frac{17}{8}$
        3. $z = \frac{7}{3}$
        4. $x = 1$ or $x = -6$
        5. $a = \frac{1}{3}$ or $a = 2$
        6. $x = -\frac{2}{3}$ or $x = 3$
        7. $b = \frac{23}{7}$

        # Step by Step
        1. Distribute: $12x + 8 - 5x + 5 = 3x + 14$
        2. Combine like terms: $7x + 13 = 3x + 14$
        3. Subtract $3x$: $4x + 13 = 14$
        4. Subtract $13$: $4x = 1$
        5. Divide by $4$: $x = \frac{1}{4}$
        """)

    html_code = pyla.to_html()
    document_validation.validate_html(html_code, check_for=['h1'])

    if WRITE_RESULT_FILES:
        with open('tests/out/test_markdown_equations.html', 'w', encoding='utf-8') as f:
            f.write(html_code)


def test_markdown_characters():
    pyla = pyladoc.DocumentWriter()
    pyla.add_markdown(
        """
        # Special caracters

        Umlaute: ÖÄÜ öäü

        Other: ß, €, @, $, %, ~, µ

        Units: m³, cm²

        Controll characters: <, >, ", ', &, |, /, \\

        """)

    html_code = pyla.to_html()
    document_validation.validate_html(html_code, check_for=['h1'])

    if WRITE_RESULT_FILES:
        with open('tests/out/test_markdown_characters.html', 'w', encoding='utf-8') as f:
            f.write(html_code)
