-- gpu/amd.lua  –  AMD / Mesa GPU environment variables
-- Generates: hypr/env_var/gpu/amd.conf

hl.heading("AMD / MESA OPTIMIZATION")
hl.keyword("env", "WLR_RENDERER,vulkan")
hl.keyword("env", "WLR_NO_HARDWARE_CURSORS,1")
hl.keyword("env", "RADV_PERFTEST,gpl")
hl.keyword("env", "AMD_VULKAN_ICD,radv")
hl.keyword("env", "MESA_VK_WSI_PRESENT_MODE,mailbox")
hl.keyword("env", "__GL_GSYNC_ALLOWED,1")
hl.keyword("env", "__GL_VRR_ALLOWED,1")
