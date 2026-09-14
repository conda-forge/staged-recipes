# Third-party notices

`elk-worker.js` (and its minified and `elk.bundled.js` forms) is Java transpiled with the
GWT compiler. Besides the Eclipse Layout Kernel itself, the output contains transpiled code
from the projects below, compiled in from their published source artifacts (see
`build.gradle` in the elkjs repository). Source-file licence headers do not survive
transpilation, so the attributions are recorded here.

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
