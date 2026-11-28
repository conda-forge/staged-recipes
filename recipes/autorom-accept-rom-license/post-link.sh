python << EndOfLine
import pathlib
import AutoROM

download_dir = pathlib.Path(AutoROM.__file__).parent / "roms"
download_dir.mkdir(exist_ok=True, parents=True)
AutoROM.main(True, None, download_dir, False)
EndOfLine
