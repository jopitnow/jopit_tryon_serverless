# jopit_tryon_serverless

Virtual Try-On pipeline on RunPod Serverless using Qwen Image Edit.

## Build & Push

docker build -t your-dockerhub/jopit-vton:latest .
docker push your-dockerhub/jopit-vton:latest

## Deploy on RunPod

1. Go to RunPod → Serverless → New Endpoint
2. Import from Docker Registry: `your-dockerhub/jopit-vton:latest`
3. Select GPU: L4 (24GB) or A6000 (48GB)
4. Set idle timeout: 300s (recommended)

## Test

python client.py

## Input images

Images are sent as base64 in the `images` array of the request payload.
They are NOT baked into the Docker image.
