import modelcif
import modelcif.dumper
import modelcif.reader
import os

system = modelcif.System(title='test system')

entityA = modelcif.Entity('AAA', description='Subunit A')
entityB = modelcif.Entity('AAAAAA', description='Subunit B')
system.entities.extend((entityA, entityB))

# Test output in mmCIF and BinaryCIF formats
with open('output.cif', 'w') as fh:
    modelcif.dumper.write(fh, [system])

with open('output.bcif', 'wb') as fh:
    modelcif.dumper.write(fh, [system], format='BCIF')

# Make sure we can read back the files
with open('output.cif') as fh:
    sys2, = modelcif.reader.read(fh)
assert sys2.title == 'test system'

with open('output.bcif', 'rb') as fh:
    sys2, = modelcif.reader.read(fh, format='BCIF')
assert sys2.title == 'test system'

os.unlink('output.cif')
os.unlink('output.bcif')
