import genesis as gs


gs.init(backend=gs.cpu, seed=0, precision="32", logging_level="warning")

scene = gs.Scene(show_viewer=False, show_FPS=False)

# Genesis always builds the offscreen visualizer even when the interactive
# viewer is disabled. This recipe smoke test exercises the CPU simulator path
# without requiring an EGL/OSMesa context in staged-recipes CI.
scene.visualizer.build = lambda: None

scene.add_entity(morph=gs.morphs.Plane())
box = scene.add_entity(
    morph=gs.morphs.Box(
        size=(0.1, 0.1, 0.1),
        pos=(0.0, 0.0, 0.2),
    )
)
scene.build()
for _ in range(3):
    scene.step(update_visualizer=False)

pos = box.get_pos()
assert pos.shape[-1] == 3
assert float(pos[2]) < 0.2

scene.destroy()
gs.destroy()
