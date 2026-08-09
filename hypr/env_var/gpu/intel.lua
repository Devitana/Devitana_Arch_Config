-- env_var/gpu/intel.lua

----------------------------------
--- INTEL GPU OPTIMIZATION      ---
----------------------------------

hl.env("WLR_RENDERER", "vulkan")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

-- Intel Vulkan driver (for older Intel iGPU - UHD/Iris)
hl.env("VK_ICD_FILENAMES", "/usr/share/vulkan/icd.d/intel_icd.x86_64.json")
-- hl.env("VK_ICD_FILENAMES", "/usr/share/vulkan/icd.d/intel_hasvk_icd.x86_64.json") -- For newer Intel Arc GPU

hl.env("INTEL_PRECISE_TRIG", "1")
hl.env("MESA_LOADER_DRIVER_OVERRIDE", "iris")

hl.env("MESA_VK_WSI_PRESENT_MODE", "mailbox")
hl.env("__GL_GSYNC_ALLOWED", "1")
hl.env("__GL_VRR_ALLOWED", "1")