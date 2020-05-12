#!/usr/bin/env bash

mkdir build
cd build
npm install ../frontend

npm run build ../frontend

cd ../
