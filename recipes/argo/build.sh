#!/bin/sh

GOBIN=$PREFIX/bin go install -ldflags "-X main.version={{ version }}" . 
