#include <vector>
#include <vcg/complex/complex.h>
#include <vcg/complex/algorithms/update/normal.h>
#include <wrap/io_trimesh/import_ply.h>
#include <wrap/io_trimesh/import_fbx.h>

class MyVertex;
class MyFace;
struct MyUsedTypes : public vcg::UsedTypes<vcg::Use<MyVertex>::AsVertexType, vcg::Use<MyFace>::AsFaceType> {};
class MyVertex : public vcg::Vertex<MyUsedTypes, vcg::vertex::Coord3f, vcg::vertex::Normal3f, vcg::vertex::BitFlags> {};
class MyFace : public vcg::Face<MyUsedTypes, vcg::face::VertexRef, vcg::face::Normal3f, vcg::face::BitFlags> {};
class MyMesh : public vcg::tri::TriMesh<std::vector<MyVertex>, std::vector<MyFace>> {};

int main() {
    MyMesh m;
    vcg::tri::Allocator<MyMesh>::AddVertices(m, 3);
    vcg::tri::Allocator<MyMesh>::AddFaces(m, 1);
    vcg::tri::UpdateNormal<MyMesh>::PerFace(m);
    // instantiate the FBX importer against conda-forge's openfbx (not called)
    int (*open_fbx)(MyMesh&, const char*, vcg::CallBackPos*) = &vcg::tri::io::ImporterFBX<MyMesh>::Open;
    return open_fbx == nullptr;
}
