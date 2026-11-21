import os
import tempfile

from anki.collection import Collection

with tempfile.TemporaryDirectory() as tmp:
    col = Collection(os.path.join(tmp, "collection.anki2"))
    note = col.newNote()
    note["Front"] = "hello"
    note["Back"] = "world"
    col.add_note(note, col.decks.id("Default"))
    assert col.note_count() == 1
    assert col.find_notes("hello") == [note.id]
    col.close()
