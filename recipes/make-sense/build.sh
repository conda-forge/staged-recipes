#!/usr/bin/env bash

tgz=$(npm pack)
npm install -g $tgz