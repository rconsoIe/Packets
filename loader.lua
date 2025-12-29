local Packets = {}
Packets.version = "main"

function Packets.init()
    local url = string.format(
        "https://raw.githubusercontent.com/rconsoIe/Packets/@%s/main.lua",
        Packets.version
    )

    local impl = loadstring(game:HttpGet(url))()
    for k, v in pairs(impl) do
        Packets[k] = v
    end
end

return Packets
