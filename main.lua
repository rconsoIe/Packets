local Packet = {}

local RemoteCache = {}

local function findChildIgnoreCase(parent, name)
    local lower = string.lower(name)
    for _, child in ipairs(parent:GetChildren()) do
        if string.lower(child.Name) == lower then
            return child
        end
    end
end

local function resolvePath(path)
    local key = string.lower(path)
    if RemoteCache[key] then
        return RemoteCache[key]
    end

    local current = game
    for segment in string.gmatch(path, "[^%.]+") do
        current = findChildIgnoreCase(current, segment)
        if not current then
            return
        end
    end

    RemoteCache[key] = current
    return current
end

function Packet.create(data)
    if type(data) ~= "table" or type(data.path) ~= "string" then
        return
    end

    local remote = resolvePath(data.path)
    if not remote then
        return
    end

    local args = data.args or {}

    if remote:IsA("RemoteEvent") then
        remote:FireServer(args)
    elseif remote:IsA("RemoteFunction") then
        return remote:InvokeServer(args)
    end
end

return Packet
