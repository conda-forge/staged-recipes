import os

prefix = os.environ["LIBRARY_PREFIX"].replace("\\", "/")

makefiles = [
    ("pc\\Makefile", "Makefile"),
    ("pc\\Makefile.ext", "extension\\Makefile"),
]

for in_path, out_path in makefiles:
    with open(in_path) as fp_in:
        print("Patching", in_path)
        with open(out_path, "w+") as fp_out:
            print("...to", out_path)
            for line in fp_in.readlines():
                if line.startswith("prefix = "):
                    print("...setting prefix", prefix)
                    fp_out.write("prefix = {}\n".format(prefix))
                else:
                    fp_out.write(line)
