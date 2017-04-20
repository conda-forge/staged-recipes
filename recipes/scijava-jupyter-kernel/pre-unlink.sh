#!/bin/bash -euo

"${PREFIX}/bin/jupyter" kernelspec remove -fy scijava-python
"${PREFIX}/bin/jupyter" kernelspec remove -fy scijava-groovy
"${PREFIX}/bin/jupyter" kernelspec remove -fy scijava-java
"${PREFIX}/bin/jupyter" kernelspec remove -fy scijava-clojure
"${PREFIX}/bin/jupyter" kernelspec remove -fy scijava-r
"${PREFIX}/bin/jupyter" kernelspec remove -fy scijava-scala
"${PREFIX}/bin/jupyter" kernelspec remove -fy scijava-beanshell
"${PREFIX}/bin/jupyter" kernelspec remove -fy scijava-ruby
"${PREFIX}/bin/jupyter" kernelspec remove -fy scijava-javascript
