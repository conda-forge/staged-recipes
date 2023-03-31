#!/usr/bin/env Rscript

# Quick test to confirm it can communicate with chromium browser.
# This isn't run as part of the recipe build since it was non-trivial
# to install chromium in the CentOS Docker container. However, it
# could be useful for troubleshooting

library("chromote")

message("Path to browser executable: ", find_chrome())
b <- ChromoteSession$new()
message("Version info:")
str(b$Browser$getVersion())
exit <- b$close()
