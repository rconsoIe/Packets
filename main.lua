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

local function isArray(t)
    if type(t) ~= "table" then return false end
    local count = 0
    for k in pairs(t) do
        if type(k) ~= "number" then
            return false
        end
        count += 1
    end
    return count == #t
end

local function fire(remote, args)
    if args == nil then
        remote:FireServer()
    elseif type(args) == "table" then
        if isArray(args) then
            remote:FireServer(table.unpack(args))
        else
            remote:FireServer(args)
        end
    else
        remote:FireServer(args)
    end
end

local function invoke(remote, args)
    if args == nil then
        return remote:InvokeServer()
    elseif type(args) == "table" then
        if isArray(args) then
            return remote:InvokeServer(table.unpack(args))
        else
            return remote:InvokeServer(args)
        end
    else
        return remote:InvokeServer(args)
    end
end

function Packet.create(data)
    if type(data) ~= "table" or type(data.path) ~= "string" then
        return
    end

    local remote = resolvePath(data.path)
    if not remote then
        return
    end

    if remote:IsA("RemoteEvent") then
        fire(remote, data.args)
    elseif remote:IsA("RemoteFunction") then
        return invoke(remote, data.args)
    end
end

return Packet
