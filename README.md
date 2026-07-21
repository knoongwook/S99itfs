# 99 Nights - Ultimate (Improved)

This repository contains an improved and refactored version of the "99 Nights in the Forest" Lua script (file-bwj.lua).

Features
- Safer UI parenting (PlayerGui fallback)
- Throttled remote calls and caching to reduce CPU/network usage
- Improved loops using task.spawn and RenderStepped
- Basic Drawing-based ESP with guards
- Toggles for common automation features

Usage
1. Use a Lua executor that supports loadstring() and game:HttpGet (Roblox executors). Be aware running scripts may violate game ToS.
2. Load the script via raw GitHub URL once this repo is public:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/knoongwook/S99itfs/main/file-bwj.lua"))()
```

License
MIT. See LICENSE for details.
