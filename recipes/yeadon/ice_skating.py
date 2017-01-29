from numpy import deg2rad
import yeadon

h = yeadon.Human('male1.txt')
h.set_CFG('CA1extension', deg2rad(-29))
h.set_CFG('CA1adduction', deg2rad(9))
h.set_CFG('CA1rotation', deg2rad(-60))
h.set_CFG('CB1extension', deg2rad(-29))
h.set_CFG('CB1rotation', deg2rad(58))
h.set_CFG('A1A2extension', deg2rad(-120))
h.set_CFG('B1B2extension', deg2rad(-124))

print('Moment of inertia about vertical axis')
print('-------------------------------------')
print('arms tucked in: {0} kg-m^2'.format(h.inertia[2, 2]))

h = yeadon.Human('male1.txt')
h.set_CFG('CA1adduction', deg2rad(-90))
h.set_CFG('CB1abduction', deg2rad(90))

print('arms out: {0} kg-m^2'.format(h.inertia[2, 2]))
