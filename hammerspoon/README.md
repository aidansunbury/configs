# HammerSpoon Config

This is not the actual config file that hammerspoon sources. Instead, add this line:

```lua
dofile(os.getenv("HOME") .. "/.config/hammerspoon/init.lua")
```

To `.hammerspoon/init.lua` to source the config from here