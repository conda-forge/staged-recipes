import zipfile

ZIP_PATH = "FRI-Client-SDK_Cpp.zip"
HTML_PATH = "doc/html/index.html"
OUT_PATH = "LICENSE-KUKA-Sunrise-Connectivity-FRI-Client-SDK.txt"


def main() -> None:
    with zipfile.ZipFile(ZIP_PATH) as zf:
        data = zf.read(HTML_PATH)

    text = data.decode("utf-8", errors="ignore")
    anchor = 'name="FRILicense"'
    h = text.find(anchor)
    i = text.find("<pre", h) if h != -1 else -1
    i = text.find(">", i) + 1 if i != -1 else -1
    j = text.find("</pre>", i) if i != -1 else -1

    if h == -1 or i == -1 or j == -1:
        raise SystemExit("KUKA license not found in doc/html/index.html")

    license_block = text[i:j].strip()
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        f.write(license_block + "\n")


if __name__ == "__main__":
    main()
