# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base

# ============================================================
# 1. CUSTOM NODES
# ============================================================
# Florence2 (classification)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-Florence2.git && \
    cd ComfyUI-Florence2 && \
    pip install -r requirements.txt

# Impact Pack (ImpactSwitch for routing)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git && \
    cd ComfyUI-Impact-Pack && \
    pip install -r requirements.txt && \
    python install.py

# Impact Subpack (required by some Impact Pack features)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git && \
    cd ComfyUI-Impact-Subpack && \
    pip install -r requirements.txt

# KJNodes (ImageConcanate for side-by-side composite)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-KJNodes.git && \
    cd ComfyUI-KJNodes && \
    pip install -r requirements.txt

# ============================================================
# 2. MODELS — Base (UNET, CLIP, VAE)
# ============================================================
RUN comfy model download \
    --url https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_fp8_e4m3fn.safetensors \
    --relative-path models/diffusion_models \
    --filename qwen_image_edit_fp8_e4m3fn.safetensors

RUN comfy model download \
    --url https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors \
    --relative-path models/clip \
    --filename qwen_2.5_vl_7b_fp8_scaled.safetensors

RUN comfy model download \
    --url https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors \
    --relative-path models/vae \
    --filename qwen_image_vae.safetensors

# ============================================================
# 3. LORAS — Lightning + TryOn + Extractor
# ============================================================
RUN comfy model download \
    --url https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Lightning-4steps-V1.0.safetensors \
    --relative-path models/loras \
    --filename Qwen-Image-Lightning-4steps-V1.0.safetensors

# Create subdirectory for Qwen edit LoRAs (forward slashes for Linux!)
RUN mkdir -p /comfyui/models/loras/qwen/edit

RUN comfy model download \
    --url "https://civitai.com/api/download/models/2196278?type=Model&format=SafeTensor" \
    --relative-path models/loras/qwen/edit \
    --filename clothes_tryon_qwen-edit-lora.safetensors

RUN comfy model download \
    --url "https://civitai.com/api/download/models/2196307?type=Model&format=SafeTensor" \
    --relative-path models/loras/qwen/edit \
    --filename outfit_extractor_qwen-edit-lora.safetensors

# ============================================================
# 4. FLORENCE2 MODEL (pre-download to avoid cold start penalty)
# ============================================================
RUN python -c "from huggingface_hub import snapshot_download; snapshot_download('microsoft/Florence-2-base-ft', local_dir='/comfyui/models/LLM/microsoft--Florence-2-base-ft')"