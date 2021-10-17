diff --git a/setup.py b/setup.py
index dd945fe..16205bd 100644
--- a/setup.py
+++ b/setup.py
@@ -59,7 +59,6 @@ setuptools.setup(
         "Pillow>=7.1",
     ],
     extras_require={"gui": ["wxpython<4.1"]},
-    scripts=["deeplabcut/pose_estimation_tensorflow/models/pretrained/download.sh"],
     packages=setuptools.find_packages(),
     data_files=[
         (
