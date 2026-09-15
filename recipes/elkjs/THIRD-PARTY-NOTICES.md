# Third-party notices

The files under `lib/` are build products that carry code from other projects with them.
Source-file licence headers do not survive either GWT transpilation or JavaScript bundling,
so the attributions are recorded here.

## Transpiled into `elk-worker.js`

`elk-worker.js`, its minified form and `elk.bundled.js` are Java compiled to JavaScript by
the GWT compiler. Besides the Eclipse Layout Kernel itself, the output contains transpiled
code from the projects below, compiled in from their published source artifacts (see
`build.gradle` in the elkjs repository).

- Eclipse Layout Kernel 0.9.3 (`org.eclipse.elk.*`)
  Copyright (c) Kiel University, TypeFox GmbH and others. EPL-2.0, see `LICENSE.md`.
  https://github.com/eclipse-elk/elk

- Xtext xbase runtime library 2.28.0 (`org.eclipse.xtext.xbase.lib`)
  Copyright (c) itemis AG, Universite de Technologie de Belfort-Montbeliard and others.
  EPL-2.0, see `LICENSE.md`.
  https://github.com/eclipse-xtext/xtext

- EMF for GWT 2.12.4 (`org.eclipse.emf.common`, `org.eclipse.emf.ecore`), GenMyModel's port
  of the Eclipse Modeling Framework
  Copyright (c) IBM Corporation, Ed Merks, TIBCO Software Inc., Zeligsoft Inc., Kenn Hussey,
  itemis AG, CEA and others. EPL-1.0, see `LICENSE-EPL-1.0.txt`.
  The regular-expression and datatype code in `org.eclipse.emf.ecore.xml.type.internal`
  (`RegEx`, `DataValue`) is derived from Apache Xerces, Copyright (c) 1999-2004 The Apache
  Software Foundation, and is additionally under the Apache Software License 1.1, see
  `LICENSE-Apache-1.1.txt`. This product includes software developed by the Apache Software
  Foundation (http://www.apache.org/).
  https://github.com/Axellience/emfgwt

- Guava 31.1 for GWT (`com.google.common.base`, `com.google.common.collect`)
  Copyright (C) The Guava Authors. Apache-2.0, see `LICENSE-Apache-2.0.txt`.
  https://github.com/google/guava

- GWT 2.10.0 runtime and JRE emulation (`com.google.gwt.*`, `java.*`)
  Copyright Google Inc. The JRE emulation also contains code Copyright The Apache Software
  Foundation (from Apache Harmony) and The Android Open Source Project. All Apache-2.0, see
  `LICENSE-Apache-2.0.txt`.
  https://github.com/gwtproject/gwt

## Embedded by the JavaScript bundler

`elk-api.js` and `elk.bundled.js` were produced with Babel and browserify, which inline
some of their own runtime code into the output.

- browser-pack 6.1.0, the browserify module loader prelude, the `function r(e,n,t)` block
  at the top of each bundle
  Copyright (c) James Halliday. MIT, see `LICENSE-MIT-browser-pack.txt`.
  https://github.com/browserify/browser-pack

- umd 3.0.x, the `(function(f){...})` universal-module-definition wrapper that browser-pack
  emits for a standalone bundle
  Copyright (c) 2013 Forbes Lindesay. MIT, see `LICENSE-MIT-umd.txt`.
  https://github.com/ForbesLindesay/umd

- Babel 6 helper functions (`_classCallCheck`, `_createClass`, `_inherits`,
  `_possibleConstructorReturn`), inlined by babel-preset-env when transpiling elkjs's own
  sources
  Copyright (c) 2014-2017 Sebastian McKenzie and other contributors. MIT, see
  `LICENSE-MIT-babel.txt`.
  https://github.com/babel/babel

- web-worker 1.x, bundled into `elk.bundled.js` as the worker shim
  Copyright 2020 Google LLC. Apache-2.0, see `LICENSE-Apache-2.0.txt`.
  https://github.com/developit/web-worker
