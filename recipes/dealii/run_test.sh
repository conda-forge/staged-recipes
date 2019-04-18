#!/bin/bash -e

# {{{ test.cc

cat <<'EOF'>test.cc
#include <deal.II/grid/tria.h>
#include <deal.II/grid/tria_accessor.h>
#include <deal.II/grid/tria_iterator.h>
#include <deal.II/grid/grid_generator.h>
#include <deal.II/grid/grid_out.h>

#include <iostream>
#include <fstream>
#include <cmath>

using namespace dealii;

int main ()
{
  Triangulation<2> triangulation;
  GridGenerator::hyper_cube (triangulation);
  triangulation.refine_global (2);
  std::ofstream out ("grid.eps");
  GridOut grid_out;
  grid_out.write_eps (triangulation, out);
  std::cout << "Grid generated and written to grid.eps" << std::endl;
}
EOF

# }}}

# {{{ CMakeLists.txt

cat <<'EOF'>CMakeLists.txt
SET(TARGET "test")
SET(TARGET_SRC test.cc)

CMAKE_MINIMUM_REQUIRED(VERSION 3.0.0)
FIND_PACKAGE(deal.II 9.0.0 QUIET
  HINTS ${deal.II_DIR} ${DEAL_II_DIR} ../ ../../ $ENV{DEAL_II_DIR}
  )
IF(NOT ${deal.II_FOUND})
  MESSAGE(FATAL_ERROR "\n"
    "*** Could not locate a (sufficiently recent) version of deal.II. ***\n\n"
    "You may want to either pass a flag -DDEAL_II_DIR=/path/to/deal.II to cmake\n"
    "or set an environment variable \"DEAL_II_DIR\" that contains this path."
    )
ENDIF()

DEAL_II_INITIALIZE_CACHED_VARIABLES()
PROJECT(${TARGET})
DEAL_II_INVOKE_AUTOPILOT()
EOF

# }}}

mkdir build && cd build
cmake -DDEAL_II_DIR=${PREFIX} ..

make
make run
