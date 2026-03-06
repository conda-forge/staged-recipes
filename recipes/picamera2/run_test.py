from picamera2 import Picamera2

cameras = Picamera2.global_camera_info()
print(f"Found {len(cameras)} camera(s): {cameras}")
