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
    local count = 0
    for k in pairs(t) do
        if type(k) ~= "number" then
            return false
        end
        count += 1
    end
    return count == #t
end

local function hasCircularRef(t, seen)
    if type(t) ~= "table" then
        return false
    end

    seen = seen or {}
    if seen[t] then
        return true
    end

    seen[t] = true
    for _, v in pairs(t) do
        if type(v) == "table" and hasCircularRef(v, seen) then
            return true
        end
    end

    seen[t] = nil
    return false
end

local function fire(remote, args, raw)
    if args == nil then
        remote:FireServer()
        return
    end

    if type(args) == "table" then
        if hasCircularRef(args) then
            warn("Packets: circular reference detected, packet not sent")
            return
        end

        if raw or not isArray(args) then
            remote:FireServer(args)
        else
            remote:FireServer(table.unpack(args))
        end
    else
        remote:FireServer(args)
    end
end

local function invoke(remote, args, raw)
    if args == nil then
        return remote:InvokeServer()
    end

    if type(args) == "table" then
        if hasCircularRef(args) then
            warn("Packets: circular reference detected, packet not sent")
            return
        end

        if raw or not isArray(args) then
            return remote:InvokeServer(args)
        else
            return remote:InvokeServer(table.unpack(args))
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
        fire(remote, data.args, data.raw)
    elseif remote:IsA("RemoteFunction") then
        return invoke(remote, data.args, data.raw)
    end
end

return Packet
