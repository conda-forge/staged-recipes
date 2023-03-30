#!/usr/bin/env Rscript

# Quick test to confirm it can communicate with chromium browser

library("chromote")

b <- ChromoteSession$new()
b$view()
b$Browser$getVersion()
b$parent$close()
