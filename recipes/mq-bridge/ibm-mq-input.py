import mq_bridge_py

# 1. Define your bridge configuration
route_config = {
    "input": {
        "file": {
            "path": "./data/input_video.mp4",
            "mode": "subscribe"
        }
    },
    "publisher": {
        "memory": {
            "topic": "video_frames"
        }
    }
}

# 2. Create the route and attach a processing handler
route = (
    mq_bridge_py.Route.from_config(route_config)
    .with_handler(lambda message: process_frame(message))
)

def process_frame(message):
    # Extract raw frame bytes or structured data depending on your pipeline
    frame_data = message.bytes()

    # Insert your video processing logic here (e.g., OpenCV, decoding chunks)
    print(f"Received frame of size: {len(frame_data)} bytes")
