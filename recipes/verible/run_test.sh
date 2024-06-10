#!/bin/bash
echo "Running run_test.sh..."
echo "module   m   ;endmodule" > test.sv
echo "module m;
endmodule" > test_formatted.sv
output=$(verible-verilog-format test.sv)
if [ "$output" != "$(cat test_formatted.sv)" ]; then
    echo "Test not successful; verible-verilog-format output does not match expected"
    echo "Output: $output"
    echo "Expected: $(cat test_formatted.sv)"
    exit 1
fi

echo "a b c d e f g" > test2.sv
echo "a b c d  e f g" > test2_compare.sv
output2=$(verible-verilog-diff --mode=format test2.sv test2_compare.sv)
echo "verible-verilog-diff result: $output2"

echo "linting test..."
echo "module mod();
  assign foo = condition_a? (condition_b ? (condition_c ? a : b) : c) : d;
endmodule" > mod.sv
chmod a+wx mod.sv
output3=$(verible-verilog-lint --autofix=inplace mod.sv)
echo "verible-verilog-lint result: $output3"
echo "Tests passed."
