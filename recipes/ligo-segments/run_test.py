from ligo import segments
assert (segments.segment(1, 2) +
        segments.segment(2, 3)) == segments.segment(1, 3)
