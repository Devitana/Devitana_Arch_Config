-- env_var/gpu/generic_gpu.lua

----------------------------------
--- GENERIC WAYLAND SETTINGS    ---
----------------------------------

hl.env("WLR_RENDERER", "vulkan")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

hl.env("MESA_VK_WSI_PRESENT_MODE", "mailbox")
hl.env("__GL_GSYNC_ALLOWED", "1")
hl.env("__GL_VRR_ALLOWED", "1")

