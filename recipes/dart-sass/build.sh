#!/usr/bin/env bash

dart pub get
dart compile exe bin/sass.dart -o $PREFIX/bin/sass
