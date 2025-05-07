import math
import tempfile
from mseedlib import MSTraceList, timestr2nstime

# Generate synthetic sinusoid data, starting at 0, 45, and 90 degrees
data0 = list(map(lambda x: int(math.sin(math.radians(x)) * 500), range(0, 500)))
data1 = list(map(lambda x: int(math.sin(math.radians(x)) * 500), range(45, 500 + 45)))
data2 = list(map(lambda x: int(math.sin(math.radians(x)) * 500), range(90, 500 + 90)))

mstl = MSTraceList()

sample_rate = 40.0
start_time = timestr2nstime("2024-01-01T15:13:55.123456789Z")
format_version = 2
record_length = 512

# Add synthetic data to the trace list
mstl.add_data(sourceid="FDSN:XX_TEST__B_S_0",
              data_samples=data0, sample_type='i',
              sample_rate=sample_rate, start_time=start_time)

mstl.add_data(sourceid="FDSN:XX_TEST__B_S_0",
              data_samples=data1, sample_type='i',
              sample_rate=sample_rate, start_time=start_time)

mstl.add_data(sourceid="FDSN:XX_TEST__B_S_0",
              data_samples=data2, sample_type='i',
              sample_rate=sample_rate, start_time=start_time)

# Record handler called for each generated record
def record_handler(record, handler_data):
    handler_data['fh'].write(record)

with tempfile.TemporaryFile() as file_handle:
    # Generate miniSEED records
    mstl.pack(record_handler,
              {'fh': file_handle},
              flush_data=True)
    # file pointer should have been moved
    assert file_handle.tell() > 0
    # magic numbers at start of file, see
    # https://docs.fdsn.org/projects/miniseed3/en/latest/definition.html
    file_handle.seek(0)
    assert file_handle.read(2) == b'MS'
    # next should be an uint8 value of 3 for MiniSEED version 3
    assert file_handle.read(1) == b'\x03'
    # later on we can look for the source id and we should be ok
    file_handle.seek(40)
    assert file_handle.read(19) == b'FDSN:XX_TEST__B_S_0'
