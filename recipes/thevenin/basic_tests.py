import thevenin as thev

model = thev.Model()

expr = thev.Experiment()
expr.add_step('current_A', 75., (3600., 1.), limits=('voltage_V', 3.))

soln = model.run(expr)
soln.plot('time_h', 'voltage_V')

assert all(soln.success)