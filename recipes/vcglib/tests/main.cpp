// https://github.com/cnr-isti-vclab/vcglib/blob/main/apps/minimal_project/simple_main.cpp

#include <vcg/complex/complex.h>

class MyVertex : public vcg::Vertex<
                     MyUsedTypes,
                     vcg::vertex::Coord3f,
                     vcg::vertex::Normal3f,
                     vcg::vertex::BitFlags> {};
class MyFace : public vcg::Face<
                   MyUsedTypes,
                   vcg::face::FFAdj,
                   vcg::face::VertexRef,
                   vcg::face::BitFlags> {};
class MyEdge : public vcg::Edge<MyUsedTypes> {};

class MyMesh : public vcg::tri::TriMesh<
                   std::vector<MyVertex>,
                   std::vector<MyFace>,
                   std::vector<MyEdge>> {};

class MyVertex0
    : public vcg::
          Vertex<MyUsedTypes, vcg::vertex::Coord3f, vcg::vertex::BitFlags> {};
class MyVertex1 : public vcg::Vertex<
                      MyUsedTypes,
                      vcg::vertex::Coord3f,
                      vcg::vertex::Normal3f,
                      vcg::vertex::BitFlags> {};
class MyVertex2 : public vcg::Vertex<
                      MyUsedTypes,
                      vcg::vertex::Coord3f,
                      vcg::vertex::Color4b,
                      vcg::vertex::CurvatureDirf,
                      vcg::vertex::Qualityf,
                      vcg::vertex::Normal3f,
                      vcg::vertex::BitFlags> {};

int main(int argc, char** argv) {
  if (argc < 2) {
    printf("Usage trimesh_base <meshfilename.off>\n");
    return -1;
  }
  /*!
   */
  MyMesh m;

  vcg::tri::RequirePerVertexNormal(m);
  vcg::tri::UpdateNormal<MyMesh>::PerVertexNormalized(m);
  printf("Input mesh  vn:%i fn:%i\n", m.VN(), m.FN());

  return 0;
}
