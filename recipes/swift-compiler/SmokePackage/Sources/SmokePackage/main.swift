// Exercises Foundation, the platform C library, a C target and arguments.
import CHelper
import Foundation
#if canImport(Glibc)
import Glibc
#else
import Darwin
#endif

let json = try JSONSerialization.data(withJSONObject: ["ok": getpid() > 0])
let arguments = CommandLine.arguments.dropFirst().joined(separator: ",")
print(String(decoding: json, as: UTF8.self), strlen("abc"), helper(), arguments)
