-- gpu/generic.lua  –  generic / fallback GPU environment variables
-- Generates: hypr/env_var/gpu/generic_gpu.conf

hl.heading("GENERIC WAYLAND SETTINGS")
hl.raw("")
hl.comment("Generic Vulkan configuration")
hl.keyword("env", "WLR_RENDERER,vulkan")
hl.keyword("env", "WLR_NO_HARDWARE_CURSORS,1")
hl.raw("")
hl.comment("Generic VRR settings")
hl.keyword("env", "__GL_GSYNC_ALLOWED,1")
hl.keyword("env", "__GL_VRR_ALLOWED,1")
hl.raw("")
hl.comment("Default present mode")
hl.keyword("env", "MESA_VK_WSI_PRESENT_MODE,mailbox")
