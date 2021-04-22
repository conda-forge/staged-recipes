import RMF
import os

# Make sure that we can read in an RMF file that we ourselves created
# in both modern and old (HDF5) format
for suffix in ('rmf', 'rmf-hdf5'):
    r = RMF.create_rmf_file("test.%s" % suffix)
    r.add_frame("root", RMF.FRAME)
    del r

    r = RMF.open_rmf_file_read_only("test.%s" % suffix)
    r.set_current_frame(RMF.FrameID(0))
    del r

    os.unlink("test.%s" % suffix)
