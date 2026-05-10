import genesis as gs


gs.init(backend=gs.cpu, seed=0, precision="32", logging_level="warning")

scene = gs.Scene(show_viewer=False, show_FPS=False)
scene.add_entity(morph=gs.morphs.Plane())
box = scene.add_entity(
    morph=gs.morphs.Box(
        size=(0.1, 0.1, 0.1),
        pos=(0.0, 0.0, 0.2),
    )
)
scene.build()
scene.step()

assert box.get_pos().shape[-1] == 3

scene.destroy()
gs.destroy()
