#include "ZXing/MultiFormatWriter.h"
#include "ZXing/BitMatrix.h"
#include "ZXing/ReadBarcode.h"

#include <vector>

int main()
{
	using namespace ZXing;

	BitMatrix matrix = MultiFormatWriter(BarcodeFormat::QRCode).setMargin(2).encode("hello conda-forge", 200, 200);

	std::vector<uint8_t> pixels(matrix.width() * matrix.height());
	for (int y = 0; y < matrix.height(); ++y)
		for (int x = 0; x < matrix.width(); ++x)
			pixels[y * matrix.width() + x] = matrix.get(x, y) ? 0 : 255;

	ImageView image(pixels.data(), matrix.width(), matrix.height(), ImageFormat::Lum);

	ReaderOptions opts;
	opts.setFormats(BarcodeFormat::QRCode);
	Barcode barcode = ReadBarcode(image, opts);

	return barcode.isValid() && barcode.text() == "hello conda-forge" ? 0 : 1;
}
