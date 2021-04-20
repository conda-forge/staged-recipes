import ihm
import ihm.dumper
import ihm.reader
import os

system = ihm.System(title='test system')

entityA = ihm.Entity('AAA', description='Subunit A')
entityB = ihm.Entity('AAAAAA', description='Subunit B')
system.entities.extend((entityA, entityB))

# Test output in mmCIF and BinaryCIF formats
with open('output.cif', 'w') as fh:
    ihm.dumper.write(fh, [system])

with open('output.bcif', 'wb') as fh:
    ihm.dumper.write(fh, [system], format='BCIF')

# Make sure we can read back the files
with open('output.cif') as fh:
    sys2, = ihm.reader.read(fh)
assert sys2.title == 'test system'

with open('output.bcif', 'rb') as fh:
    sys2, = ihm.reader.read(fh, format='BCIF')
assert sys2.title == 'test system'

os.unlink('output.cif')
os.unlink('output.bcif')
