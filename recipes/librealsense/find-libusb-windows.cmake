--- a/CMake/libusb_config.cmake
+++ b/CMake/libusb_config.cmake
@@ -1,5 +1,5 @@
 if (NOT TARGET usb)
-    find_library(LIBUSB_LIB usb-1.0)
+    find_library(LIBUSB_LIB usb-1.0 libusb-1.0)
     find_path(LIBUSB_INC libusb.h HINTS PATH_SUFFIXES libusb-1.0)
     include(FindPackageHandleStandardArgs)
     find_package_handle_standard_args(usb "libusb not found; using internal version" LIBUSB_LIB LIBUSB_INC)
