import bmf

print("Version:", bmf.get_version())
print("Commit:", bmf.get_commit())

graph = bmf.graph()
video = graph.decode({"input_path": "testsrc.mp4"})["video"]
output = video.encode(None, {"null_output": 1})
output.run()
