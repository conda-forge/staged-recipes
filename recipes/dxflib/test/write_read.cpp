// Write a DXF with one line, read it back and check the coordinates
#include <dl_creationadapter.h>
#include <dl_dxf.h>

#include <cmath>
#include <cstdio>

struct Reader : DL_CreationAdapter
{
	int lines = 0;
	double x2 = 0;
	void addLine(const DL_LineData& d) override
	{
		++lines;
		x2 = d.x2;
	}
};

int main()
{
	DL_Dxf dxf;
	DL_WriterA* dw = dxf.out("test.dxf", DL_Codes::AC1015);
	if (!dw)
		return 1;
	dxf.writeHeader(*dw);
	dw->sectionEnd();
	dw->sectionEntities();
	dxf.writeLine(*dw, DL_LineData(0.0, 0.0, 0.0, 2.5, 1.0, 0.0), DL_Attributes("0", 256, -1, "BYLAYER", 1.0));
	dw->sectionEnd();
	dxf.writeObjects(*dw);
	dxf.writeObjectsEnd(*dw);
	dw->dxfEOF();
	dw->close();
	delete dw;

	Reader reader;
	if (!DL_Dxf().in("test.dxf", &reader))
		return 2;
	std::printf("lines: %d, x2: %g\n", reader.lines, reader.x2);
	return (reader.lines == 1 && std::fabs(reader.x2 - 2.5) < 1e-9) ? 0 : 3;
}
