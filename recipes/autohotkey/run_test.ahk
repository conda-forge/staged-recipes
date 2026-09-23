; Expects the package version as its single command-line argument.
if A_Args.Length != 1
    ExitApp 1
if A_AhkVersion != A_Args[1]
    ExitApp 1
ExitApp 0
