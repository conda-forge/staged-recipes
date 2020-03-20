import unittest
import jupyter_kernel_test

class XCppTests(jupyter_kernel_test.KernelTests):

    kernel_name = 'xcpp17'

    # language_info.name in a kernel_info_reply should match this
    language_name = 'c++'

    # Code in the kernel's language to print a small table to stdout
    code_create_table = '#include <tabulate/table.hpp>\nusing namespace tabulate;\nint main() {\n\nTable universal_constants;\nuniversal_constants.add_row({"Quantity", "Value"});\n  universal_constants.add_row({"Characteristic impedance of vacuum", "376.730 313 461... Ω"});\n'

    # TODO: add more tests here
    
if __name__ == '__main__':
    unittest.main()
