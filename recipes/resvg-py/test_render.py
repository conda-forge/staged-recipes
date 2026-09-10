"""Render a trivial SVG and check we get a real PNG back.

Verifies the compiled extension actually works, rather than merely importing.
"""

import resvg_py

SVG = """
<svg xmlns="http://www.w3.org/2000/svg" width="8" height="8">
  <rect width="8" height="8" fill="red" />
</svg>
"""

png = bytes(resvg_py.svg_to_bytes(svg_string=SVG))

assert png.startswith(b"\x89PNG\r\n\x1a\n"), png[:16]
assert resvg_py.__resvg_version__, "resvg version not reported"

print(f"resvg_py {resvg_py.__version__} (resvg {resvg_py.__resvg_version__}): {len(png)} byte PNG")
