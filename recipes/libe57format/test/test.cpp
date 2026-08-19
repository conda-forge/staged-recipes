#include <E57Format/E57SimpleReader.h>
#include <E57Format/E57SimpleWriter.h>

#include <cstdio>
#include <cstdint>
#include <vector>

int main()
{
    const char fileName[] = "e57-test.e57";
    const int64_t numPoints = 8;

    {
        e57::WriterOptions options;
        options.guid = "conda-forge-libe57format-test";
        e57::Writer writer(fileName, options);

        e57::Data3D header;
        header.guid = "conda-forge-libe57format-test-scan";
        header.pointCount = numPoints;
        header.pointFields.cartesianXField = true;
        header.pointFields.cartesianYField = true;
        header.pointFields.cartesianZField = true;

        std::vector<double> x(numPoints), y(numPoints), z(numPoints);
        for (int64_t i = 0; i < numPoints; ++i)
        {
            x[i] = static_cast<double>(i);
            y[i] = static_cast<double>(i) * 2.0;
            z[i] = static_cast<double>(i) * 3.0;
        }

        e57::Data3DPointsDouble buffers;
        buffers.cartesianX = x.data();
        buffers.cartesianY = y.data();
        buffers.cartesianZ = z.data();

        const int64_t scanIndex = writer.NewData3D(header);
        e57::CompressedVectorWriter dataWriter =
            writer.SetUpData3DPointsData(scanIndex, numPoints, buffers);
        dataWriter.write(static_cast<size_t>(numPoints));
        dataWriter.close();
        writer.Close();
    }

    {
        e57::Reader reader(fileName, {});
        if (reader.GetData3DCount() != 1)
        {
            std::fprintf(stderr, "expected 1 scan, got %lld\n",
                         static_cast<long long>(reader.GetData3DCount()));
            return 1;
        }

        e57::Data3D header;
        if (!reader.ReadData3D(0, header) || header.pointCount != numPoints)
        {
            std::fprintf(stderr, "failed to read scan header\n");
            return 1;
        }
        reader.Close();
    }

    std::remove(fileName);
    return 0;
}
