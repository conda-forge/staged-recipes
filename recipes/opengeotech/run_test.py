import opengeotech

# Test effective_stress function
result = opengeotech.effective_stress(100, 40)
assert result == 60, f"Expected 60, got {result}"

print("All tests passed!") 