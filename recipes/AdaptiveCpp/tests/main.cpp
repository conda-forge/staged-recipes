#ifdef WIN32
  #include <SYCL/sycl.hpp>
#else
  #include <sycl/sycl.hpp>
#endif

#include <iostream>

int main(int argc, char** argv) {
  try {
    // Get all available SYCL platforms
    std::vector<sycl::platform> platforms = sycl::platform::get_platforms();

    std::cout << "Available platforms: " << platforms.size() << "\n\n";
    for (const auto& plt : platforms) {
      std::cout << "Platform: " << plt.get_info<sycl::info::platform::name>() << "\n";
      std::cout << "Vendor: " << plt.get_info<sycl::info::platform::vendor>() << "\n";
      std::cout << "Version: " << plt.get_info<sycl::info::platform::version>() << "\n\n";

      // Get all devices in this platform
      std::vector<sycl::device> devices = plt.get_devices();

      std::cout << "  Number of devices in this platform: " << devices.size() << "\n";
      for (const auto& dev : devices) {
        std::cout << "    Device Name  : " << dev.get_info<sycl::info::device::name>() << "\n";
        std::cout << "    Vendor       : " << dev.get_info<sycl::info::device::vendor>() << "\n";
        std::cout << "    Driver       : " << dev.get_info<sycl::info::device::driver_version>()
                  << "\n";
        std::cout << "    Device Type  : ";
        switch (dev.get_info<sycl::info::device::device_type>()) {
          case sycl::info::device_type::cpu:
            std::cout << "CPU\n";
            break;
          case sycl::info::device_type::gpu:
            std::cout << "GPU\n";
            break;
          case sycl::info::device_type::accelerator:
            std::cout << "Accelerator\n";
            break;
          case sycl::info::device_type::host:
            std::cout << "Host\n";
            break;
          default:
            std::cout << "Unknown\n";
            break;
        }

        // Print out some device capabilities
        std::cout << "    Max Compute Units: "
                  << dev.get_info<sycl::info::device::max_compute_units>() << "\n";
        std::cout << "    Max Work Group Size: "
                  << dev.get_info<sycl::info::device::max_work_group_size>() << "\n\n";
      }

      std::cout << "--------------------------------------\n\n";
    }

  } catch (sycl::exception const& e) {
    std::cerr << "SYCL Exception: " << e.what() << "\n";
    return 1;
  }

  return 0;
}
