diff --git a/pyproject.toml b/pyproject.toml
index 6e1b414..99264d4 100644
--- a/pyproject.toml
+++ b/pyproject.toml
@@ -49,7 +49,7 @@ dependencies = [
 "CI" = "https://github.com/althonos/pronto/actions"
 
 [tool.setuptools.packages]
-find = {namespaces = false}
+find = {namespaces = false, exclude = ["tests*"]}
 
 [tool.setuptools.dynamic]
 version = {attr = "pronto.__version__"}
