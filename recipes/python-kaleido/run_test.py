from kaleido.scopes.plotly import PlotlyScope
scope = PlotlyScope()
assert scope.transform({"data": []}).startswith(b'\x89PNG')
