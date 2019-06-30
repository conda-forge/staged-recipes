#!/usr/bin/env bash
{
  "${PREFIX}/bin/jupyter-bundlerextension" enable --py jupyter_docx_bundler --sys-prefix
} >>"$PREFIX/.messages.txt" 2>&1
