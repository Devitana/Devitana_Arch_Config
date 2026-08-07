-- programs.lua
-- Source-of-truth for hypr/autostart/programs.conf
-- Defines program variable shortcuts used in keybindings and startup.

return {
  header = "###################\n### MY PROGRAMS ###\n###################\n",
  vars = {
    -- Variable name = command
    { name = "terminal",    value = "kitty",         comment = "Set programs that you use" },
    { name = "fileManager", value = "nautilus" },
    { name = "menu",        value = "hyprlauncher" },
  },
}
