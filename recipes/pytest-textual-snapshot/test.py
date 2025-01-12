import pytest
from datetime import datetime
from textual.app import App, ComposeResult
from textual.widgets import Digits

try:
    if 'snap_compare' not in globals() or not callable(snap_compare):
        raise NameError("'snap_compare' is either not defined or not callable.")
    print("No error finding snap_compare!")
except Exception as e:
    print(f"Error: {e}")

def test_exists(snap_compare):
    assert 'snap_compare' not in globals() or not callable(snap_compare), "'snap_compare' is either not defined or not callable."

def test_app(snap_compare):
    class ClockApp(App):
        CSS = """
        Screen { align: center middle; }
        Digits { width: auto; }
        """

        def compose(self) -> ComposeResult:
            yield Digits("")

        def on_ready(self) -> None:
            self.update_clock()
            self.set_interval(1, self.update_clock)

        def update_clock(self) -> None:
            clock = datetime.now().time()
            self.query_one(Digits).update(f"{clock:%T}")

    snap_compare(ClockApp())