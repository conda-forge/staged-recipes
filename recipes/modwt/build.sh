#!/bin/#!/usr/bin/env bash

sed -i 's/-static/-static-libgcc/' Makefile;

make;
