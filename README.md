# Packets

Small helper module to make Roblox remotes easier to use.

Instead of calling `RemoteEvent:FireServer()` everywhere, this lets you send remotes using a string path, kind of like packets / RPC calls.

This is meant for convenience and consistency, not security.

---

## What it does

- Lets you fire remotes by path string
- Path matching is case-insensitive
- Works with RemoteEvents and RemoteFunctions
- Arguments are optional
- Caches resolved remotes

Pure Lua, nothing fancy.

---

## Setup

Drop the module somewhere the client can require it or require it with `loadstring(game:HttpGet("https://raw.githubusercontent.com/rconsoIe/Packets/refs/heads/main/main.lua"))()`

## Require

```lua
local Packets = loadstring(game:HttpGet("https://raw.githubusercontent.com/rconsoIe/Packets/refs/heads/main/main.lua"))()
```
