// Write a DXF with one line, read it back and check the coordinates
#include <dl_creationadapter.h>
#include <dl_dxf.h>

#include <cmath>
#include <cstdio>
#include <string>

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

// Writes a DXF with one line to `file` (a const char*, std::string or, on Windows, std::wstring name)
template <typename Name>
bool writeLine(const Name& file)
{
	DL_Dxf dxf;
	DL_WriterA* dw = dxf.out(file, DL_Codes::AC1015);
	if (!dw)
		return false;
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
	return true;
}

template <typename Name>
int check(const Name& file)
{
	Reader reader;
	if (!DL_Dxf().in(file, &reader))
		return 2;
	std::printf("lines: %d, x2: %g\n", reader.lines, reader.x2);
	return (reader.lines == 1 && std::fabs(reader.x2 - 2.5) < 1e-9) ? 0 : 3;
}

int main()
{
	if (!writeLine("test.dxf")) // const char*
		return 1;
	if (int r = check("test.dxf"))
		return r;

	const std::string name = "test_string.dxf";
	if (!writeLine(name))
		return 1;
	if (int r = check(name))
		return r;

#ifdef _MSC_VER
	// a name outside the ANSI code page
	const std::wstring wname = L"test_\u00e9\u4e2d\u6587.dxf";
	if (!writeLine(wname))
		return 1;
	return check(wname);
#else
	return 0;
#endif
}
