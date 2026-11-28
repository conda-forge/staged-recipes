"""A scene for the package's test: typeset text, drawn on the GPU and encoded to MP4."""

import manimgx as m


class Smoke(m.Scene):
    def construct(self) -> None:
        self.play(m.Write(m.Text("manimgx")))
