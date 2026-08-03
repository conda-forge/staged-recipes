def main : IO Unit :=
  IO.println "Lean 4 works"

example (n : Nat) : n + 0 = n := by
  simp
