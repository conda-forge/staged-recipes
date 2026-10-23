// Load the MaterialX standard data libraries found through
// getDefaultDataSearchPath() and generate GLSL for standard_surface, the
// path a renderer such as OpenUSD's Storm takes.
#include <MaterialXCore/Document.h>
#include <MaterialXFormat/Util.h>
#include <MaterialXGenGlsl/GlslShaderGenerator.h>
#include <MaterialXGenShader/GenContext.h>
#include <MaterialXGenShader/Shader.h>

#include <iostream>

namespace mx = MaterialX;

int main()
{
    mx::FileSearchPath searchPath = mx::getDefaultDataSearchPath();
    std::cout << "data search path: " << searchPath.asString() << std::endl;
    if (searchPath.isEmpty())
    {
        std::cerr << "getDefaultDataSearchPath() found no data libraries" << std::endl;
        return 1;
    }

    mx::DocumentPtr stdlib = mx::createDocument();
    mx::loadLibraries({ "libraries" }, searchPath, stdlib);
    if (!stdlib->getNodeDef("ND_standard_surface_surfaceshader"))
    {
        std::cerr << "standard_surface node definition not found" << std::endl;
        return 1;
    }

    mx::DocumentPtr doc = mx::createDocument();
    doc->importLibrary(stdlib);
    mx::NodePtr shader = doc->addNode("standard_surface", "SR_test", mx::SURFACE_SHADER_TYPE_STRING);
    doc->addMaterialNode("M_test", shader);
    std::string message;
    if (!doc->validate(&message))
    {
        std::cerr << "invalid document: " << message << std::endl;
        return 1;
    }

    mx::GenContext context(mx::GlslShaderGenerator::create());
    context.registerSourceCodeSearchPath(searchPath);
    mx::ShaderPtr glsl = context.getShaderGenerator().generate("SR_test", shader, context);
    if (!glsl || glsl->getSourceCode(mx::Stage::PIXEL).empty())
    {
        std::cerr << "GLSL generation failed" << std::endl;
        return 1;
    }
    std::cout << "generated " << glsl->getSourceCode(mx::Stage::PIXEL).size()
              << " bytes of GLSL pixel shader" << std::endl;
    return 0;
}
