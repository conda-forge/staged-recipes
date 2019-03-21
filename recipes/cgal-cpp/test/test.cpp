// Based on minimal example in https://github.com/CGAL/cgal/wiki/How-to-use-CGAL-with-CMake-or-your-own-build-system
// but with Qt dependency removed

#include <CGAL/Exact_predicates_exact_constructions_kernel_with_sqrt.h>
#include <CGAL/Surface_mesh.h>
#include <CGAL/boost/graph/helpers.h>

#include <CGAL/Exact_predicates_exact_constructions_kernel.h>
#include <CGAL/Boolean_set_operations_2.h>

typedef CGAL::Exact_predicates_exact_constructions_kernel_with_sqrt K;
typedef K::Point_3 Point;
typedef CGAL::Surface_mesh<Point> Mesh;

typedef CGAL::Exact_predicates_exact_constructions_kernel Kernel;
typedef Kernel::Point_2                                   Point_2;
typedef CGAL::Polygon_2<Kernel>                           Polygon_2;

int main()
{
  Mesh m;
  CGAL::make_icosahedron<Mesh, Point>(m);

  // This part is based on Boolean_set_operations_2/do_intersect.cpp
  Polygon_2 P;
  P.push_back (Point_2 (-1,1));
  P.push_back (Point_2 (0,-1));
  P.push_back (Point_2 (1,1));
  Polygon_2 Q;
  Q.push_back(Point_2 (-1,-1));
  Q.push_back(Point_2 (1,-1));
  Q.push_back(Point_2 (0,1));

  if ((CGAL::do_intersect (P, Q))) {
    std::cout << "The two polygons intersect in their interior." << std::endl;
    return 0;
  } else {
    std::cout << "The two polygons do not intersect, but should." << std::endl;
    return 1;
  }
}
