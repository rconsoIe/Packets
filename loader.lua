local Packets = {}

Packets.version = nil
Packets._loaded = false

function Packets.init()
    if Packets._loaded then
        return Packets
    end

    local version = Packets.version
    local path

    if version and version ~= "" then
        path = "@%s/main.lua"
        path = string.format(path, version)
    else
        path = "main/main.lua"
    end

    local url = "https://raw.githubusercontent.com/rconsoIe/Packets/" .. path

    local ok, impl = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if not ok or type(impl) ~= "table" then
        error("Packets: failed to load implementation (" .. path .. ")")
    end

    for k, v in pairs(impl) do
        Packets[k] = v
    end

    Packets._loaded = true
    return Packets
end

return Packets
