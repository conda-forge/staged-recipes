"""The installed module reads the QR code and the Code 128 of the mixed fixture in every profile.

  python test_scan.py IMAGE
"""
import sys

import qrcode_barcode_scanner

WANTED = {("qr_code", "https://qrc-ai.com/76xMa"), ("code128", "STOCK-4827")}


def main(image):
    data = open(image, "rb").read()
    for profile in ("fast", "frame", "full"):
        report = qrcode_barcode_scanner.scan(data, profile=profile, budget_ms=0)
        found = {(row["symbology"], row["content"]["text"]) for row in report["detections"]}
        if found != WANTED:
            print(f"{profile}: read {sorted(found)}, expected {sorted(WANTED)}", file=sys.stderr)
            return 1
        if report["trace"].get("budget_exhausted") or report["trace"].get("engine_panics"):
            print(f"{profile}: the scan was cut or a reader panicked", file=sys.stderr)
            return 1
        print(f"ok {profile}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
