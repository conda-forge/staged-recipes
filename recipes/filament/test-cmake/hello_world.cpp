#include <filament/Engine.h>
#include <filament/Renderer.h>
#include <filament/Scene.h>
#include <filament/Skybox.h>
#include <filament/View.h>
#include <filament/Viewport.h>

#include <utils/EntityManager.h>
#include <utils/LruCache.h>

int main() {
    using namespace filament;

    utils::LruCache<int, int> cache("filament-conda-test-cache", 1);
    cache.put(1, 1, [](int&&) {});
    if (cache.get(1) == nullptr) {
        return 1;
    }

    Engine* engine = Engine::create(Engine::Backend::NOOP);
    if (engine == nullptr) {
        return 1;
    }

    SwapChain* swapChain = engine->createSwapChain(16, 16);
    Renderer* renderer = engine->createRenderer();
    Scene* scene = engine->createScene();
    Skybox* skybox = Skybox::Builder()
            .color({0.1f, 0.125f, 0.25f, 1.0f})
            .build(*engine);
    scene->setSkybox(skybox);

    utils::Entity cameraEntity = utils::EntityManager::get().create();
    Camera* camera = engine->createCamera(cameraEntity);

    View* view = engine->createView();
    view->setViewport({0, 0, 16, 16});
    view->setScene(scene);
    view->setCamera(camera);
    view->setPostProcessingEnabled(false);

    bool renderedFrame = false;
    if (renderer->beginFrame(swapChain)) {
        renderer->render(view);
        renderer->endFrame();
        renderedFrame = true;
    }

    engine->flushAndWait();

    engine->destroyCameraComponent(cameraEntity);
    utils::EntityManager::get().destroy(cameraEntity);
    engine->destroy(view);
    engine->destroy(skybox);
    engine->destroy(scene);
    engine->destroy(renderer);
    engine->destroy(swapChain);
    Engine::destroy(&engine);

    return renderedFrame ? 0 : 2;
}
