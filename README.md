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

## Documentary

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
