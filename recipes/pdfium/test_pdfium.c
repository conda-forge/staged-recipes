#include <stdio.h>
#include <fpdfview.h>
#include <fpdf_edit.h>
#include <fpdf_save.h>

int main(void) {
  FPDF_LIBRARY_CONFIG config = {0};
  config.version = 2;
  FPDF_InitLibraryWithConfig(&config);

  FPDF_DOCUMENT doc = FPDF_CreateNewDocument();
  if (!doc) { fprintf(stderr, "FPDF_CreateNewDocument failed\n"); return 1; }
  FPDF_PAGE page = FPDFPage_New(doc, 0, 612, 792);
  if (!page) { fprintf(stderr, "FPDFPage_New failed\n"); return 1; }
  if (FPDF_GetPageCount(doc) != 1) { fprintf(stderr, "unexpected page count\n"); return 1; }

  FPDF_BITMAP bitmap = FPDFBitmap_Create(612, 792, 0);
  FPDFBitmap_FillRect(bitmap, 0, 0, 612, 792, 0xFFFFFFFF);
  FPDF_RenderPageBitmap(bitmap, page, 0, 0, 612, 792, 0, 0);
  FPDFBitmap_Destroy(bitmap);

  FPDF_ClosePage(page);
  FPDF_CloseDocument(doc);
  FPDF_DestroyLibrary();
  printf("pdfium OK\n");
  return 0;
}
