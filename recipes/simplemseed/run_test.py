import io
import datetime

import numpy as np

from simplemseed import MSeed3Header, MSeed3Record, FDSNSourceId, readMSeed3Records


data = [(i % 99 - 49) for i in range(0, 1002)]
starttime = "2024-01-01T15:13:55.123456+0000"
sampling_rate = 20.0

header = MSeed3Header()
header.starttime = starttime
header.sampleRatePeriod = sampling_rate
sid = FDSNSourceId.createUnknown(header.sampleRatePeriod)
ms3record = MSeed3Record(header, sid, data)

bio = io.BytesIO()
bio.write(ms3record.pack())
bio.seek(0)
records = list(readMSeed3Records(bio))

assert len(records) == 1

record = records[0]

assert record.header.starttime == datetime.datetime.strptime(
    starttime, '%Y-%m-%dT%H:%M:%S.%f%z')
assert record.header.numSamples == len(data)
assert record.header.sampleRate == sampling_rate
np.testing.assert_array_equal(record.decompress(), data)
