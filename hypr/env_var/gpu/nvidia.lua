-- env_var/gpu/nvidia.lua

----------------------------------
--- NVIDIA OPTIMIZATION         ---
----------------------------------

hl.env("WLR_RENDERER", "vulkan")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

hl.env("__NV_PRIME_RENDER_OFFLOAD", "1")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")

hl.env("VK_ICD_FILENAMES", "/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json")

hl.env("MESA_VK_WSI_PRESENT_MODE", "fifo")
hl.env("__GL_GSYNC_ALLOWED", "1")
hl.env("__GL_VRR_ALLOWED", "1")