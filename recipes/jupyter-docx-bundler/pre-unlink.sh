#!/usr/bin/env bash
{
  "${PREFIX}/bin/jupyter-bundlerextension" disable --py jupyter_docx_bundler --sys-prefix
} >>"$PREFIX/.messages.txt" 2>&1

