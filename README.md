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

Drop the module somewhere the client can require it or require it with `loadstring(game:HttpGet("https://raw.githubusercontent.com/rconsoIe/Packets/refs/heads/main/loader.lua"))()`

## Require

```lua
local Packets = loadstring(game:HttpGet("https://raw.githubusercontent.com/rconsoIe/Packets/refs/heads/main/loader.lua"))()

-- Packets.version = "1.0.0" (this is optional, but you can still choose the version to load, it will load the last version as default)
Packets.init()
```

## Documentary

### Debug mode

```lua
local Packets = loadstring(game:HttpGet("https://raw.githubusercontent.com/rconsoIe/Packets/refs/heads/main/loader.lua"))()

-- Packets.version = "1.0.1" (optional, must be the version 1.0.1 atleast to use debug mode)
Packets.init()
Packets.debug = true -- always use after using Packets.init()
```

### Packets.create

### Usage

```lua
Packets.create({
    path = "replicatedstorage.remote1",
    args = { 1 }
})
```

- `path` is resolved starting from `game`
- casing does not matter
- do not include `game.` in the path

Valid:
replicatedstorage.remotes.remote1
ReplicatedStorage.Remotes.Remote1

Invalid:
game.ReplicatedStorage.Remotes.Remote1

### No args (arguments)

```lua
Packets.create({
        path = "replicatedstorage.remote1"
})
```

Fires the remote with no parameters.

### Positional args (RPC-style)
# If `args` is an array, values are unpacked and sent as multiple arguments

```lua
Packets.create({
    path = "replicatedstorage.remotes.remote1", 
    args = { somearg, somearg2 } 
})
```

Server receives:
```lua
 OnServerEvent(player, targetCharacter, swordName) 
```

### Named args
# If args is a dictionary table, it is sent as a single payload.

```lua
Packets.create({
    path = "replicatedstorage.remotes.remote1", 
    args = {
        something = part, 
        anotherthing = string
    }
})
```

Server receives:
```lua
OnServerEvent(player, data)
-- data.something
-- data.anotherthing
```

### Raw mode (no unpack)
Forces a table to be sent as-is, even if it looks like an array.

```lua
Packets.create({
    path = "replicatedstorage.remote1",
    args = {
        { { value = 123 } }
    },
    raw = true
})
```

### Nested tables
Deeply nested tables are supported.

```lua
Packets.create({
    path = "replicatedstorage.remote1",
    args = {
        payload = {
            a = {
                b = {
                    c = 123
                }
            }
        }
    })
```

### Circular references
Circular tables are not supported by Roblox remotes.

Invalid example:

```lua
local t = {}
t.self = t
```

Packets detects this and cancels the send to avoid silent failure.

### RemoteFunctions
If the path points to a RemoteFunction, Packets.create returns the server response.

```lua
local result = Packets.create({
    path = "replicatedstorage.remotes.getdata"
})
```

### Packets.exists

Checks if a path can be resolved to a valid instance.

Returns true if the path exists, false otherwise.

Packets.exists does not fire the remote.

Example:

```lua
Packets.exists("ReplicatedStorage.Remotes.Test")
```

Usage:

```lua
if Packets.exists("ReplicatedStorage.Remotes.Test") then
    Packets.create({
        path = "ReplicatedStorage.Remotes.Test"
    })
end
```

This uses the same path resolver as Packets.create
(case-insensitive, cached, allowOnly-aware).

---

### Packets.resolve

Resolves a path string and returns the actual Instance.

Returns the Instance if found, or nil if not found.

Example:

```
local remote = Packets.resolve("replicatedstorage.remotes.test")
print(remote)
```

This is useful for:
- debugging
- inspecting remotes
- verifying paths manually

Packets.resolve does NOT fire or invoke the remote.

---

### Packets.ping

Checks whether a path resolves to a RemoteEvent or RemoteFunction.

Returns true if:
- the path exists
- and the instance is a RemoteEvent or RemoteFunction

Returns false otherwise.

Example:

```
Packets.ping("ReplicatedStorage.Remotes.Test")
```

With debug enabled, ping will log what it finds.

This is mainly a sanity-check / debugging helper.

---

### Packets.allowOnly

Restricts which paths Packets is allowed to resolve and fire.

This is a developer safety feature, not security.

Single root:

```
Packets.allowOnly("ReplicatedStorage.Remotes")
```

Multiple roots:

```lua
Packets.allowOnly({
    "ReplicatedStorage.Remotes",
    "ReplicatedStorage.Network"
})
```

If a path is outside the allowed roots:
- it will be blocked
- nothing will be sent
- a debug message is printed (if debug is enabled)

allowOnly affects:
- Packets.create
- Packets.exists
- Packets.resolve
- Packets.ping

Paths are matched by prefix and are case-insensitive.
