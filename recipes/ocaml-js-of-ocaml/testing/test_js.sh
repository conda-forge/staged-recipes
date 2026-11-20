#!/usr/bin/env bash
# Compiles a program using the js_of_ocaml library to JavaScript and runs it under node.
set -euxo pipefail

mkdir -p jstest && cd jstest
cat > dune-project <<'DUNE'
(lang dune 3.20)
DUNE
cat > dune <<'DUNE'
(executable
 (name hello)
 (modes js)
 (libraries js_of_ocaml))
DUNE
cat > hello.ml <<'ML'
(* Js.Unsafe instead of the ## syntax, which needs js_of_ocaml-ppx *)
open Js_of_ocaml

let () =
  let console = Js.Unsafe.get Js.Unsafe.global "console" in
  Js.Unsafe.meth_call console "log"
    [| Js.Unsafe.inject (Js.string "hello from js_of_ocaml") |];
  print_endline (string_of_int (List.fold_left ( + ) 0 [ 1; 2; 3 ]))
ML
dune build --profile=release ./hello.bc.js
out="$(node _build/default/hello.bc.js)"
printf '%s\n' "${out}"
[[ "${out}" == *"hello from js_of_ocaml"* ]]
[[ "${out}" == *"6"* ]]
