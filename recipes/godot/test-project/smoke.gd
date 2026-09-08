extends SceneTree

func _initialize() -> void:
    var regex := RegEx.new()
    if regex.compile("^conda-[0-9]+$") != OK or regex.search("conda-42") == null:
        fail("Regular expression matching failed")
        return

    var original := "Godot conda-forge smoke test".to_utf8_buffer()
    for mode in [FileAccess.COMPRESSION_DEFLATE, FileAccess.COMPRESSION_ZSTD]:
        var compressed := original.compress(mode)
        if compressed.decompress(original.size(), mode) != original:
            fail("Compression round trip failed")
            return

    var source := Image.create(8, 8, false, Image.FORMAT_RGBA8)
    source.fill(Color(0.25, 0.5, 0.75, 1.0))
    var decoded := Image.new()
    if decoded.load_png_from_buffer(source.save_png_to_buffer()) != OK:
        fail("PNG round trip failed")
        return
    if decoded.get_size() != Vector2i(8, 8):
        fail("PNG dimensions changed")
        return

    var font := ThemeDB.fallback_font
    if font == null:
        fail("Built-in font is missing")
        return
    if font.get_string_size("Godot").x <= 0:
        fail("Text shaping failed")
        return

    print("Godot packaging smoke test passed")
    quit(0)

func fail(message: String) -> void:
    push_error(message)
    quit(1)
