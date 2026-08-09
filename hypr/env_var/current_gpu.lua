-- env_var/current_gpu.lua

-------------------------------
--- AMD / MESA OPTIMIZATION ---
-------------------------------

hl.env("WLR_RENDERER", "vulkan")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

hl.env("RADV_PERFTEST", "gpl")
hl.env("AMD_VULKAN_ICD", "radv")

-- hl.env("VK_ICD_FILENAMES", "/usr/share/vulkan/icd.d/radeon_icd.x86_64.json")

hl.env("MESA_VK_WSI_PRESENT_MODE", "mailbox")
hl.env("__GL_GSYNC_ALLOWED", "1")
hl.env("__GL_VRR_ALLOWED", "1")