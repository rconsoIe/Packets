local Packet = {}

Packet.version = Packet.version or "main"

local RemoteCache = {}
local AllowedRoots = nil

local function dprint(...)
	if Packet.debug then
		print("[Packets]", ...)
	end
end

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

	if AllowedRoots then
		local allowed = false
		for _, root in ipairs(AllowedRoots) do
			if key:sub(1, #root) == root then
				allowed = true
				break
			end
		end
		if not allowed then
			dprint("blocked by allowOnly:", path)
			return
		end
	end

	local current = game
	for segment in string.gmatch(path, "[^%.]+") do
		current = findChildIgnoreCase(current, segment)
		if not current then
			dprint("failed to resolve:", path)
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
	if type(t) ~= "table" then return false end
	seen = seen or {}
	if seen[t] then return true end
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
		dprint("FireServer()")
		remote:FireServer()
		return
	end

	if type(args) == "table" then
		if hasCircularRef(args) then
			warn("[Packets] circular reference detected, packet blocked")
			return
		end

		if raw or not isArray(args) then
			dprint("FireServer(table)", raw and "(raw)" or "")
			remote:FireServer(args)
		else
			dprint("FireServer(unpack)", #args, "args")
			remote:FireServer(table.unpack(args))
		end
	else
		dprint("FireServer(value)")
		remote:FireServer(args)
	end
end

local function invoke(remote, args, raw)
	if args == nil then
		dprint("InvokeServer()")
		return remote:InvokeServer()
	end

	if type(args) == "table" then
		if hasCircularRef(args) then
			warn("[Packets] circular reference detected, invoke blocked")
			return
		end

		if raw or not isArray(args) then
			dprint("InvokeServer(table)", raw and "(raw)" or "")
			return remote:InvokeServer(args)
		else
			dprint("InvokeServer(unpack)", #args, "args")
			return remote:InvokeServer(table.unpack(args))
		end
	else
		dprint("InvokeServer(value)")
		return remote:InvokeServer(args)
	end
end

-- =========================
-- API (do not change anything that isnt under this, unless you know what ur doing)
-- =========================

function Packet.create(data)
	if type(data) ~= "table" or type(data.path) ~= "string" then
		dprint("invalid create() call")
		return
	end

	local remote = resolvePath(data.path)
	if not remote then return end

	dprint("sending to:", remote.ClassName)

	if remote:IsA("RemoteEvent") then
		fire(remote, data.args, data.raw)
	elseif remote:IsA("RemoteFunction") then
		return invoke(remote, data.args, data.raw)
	else
		dprint("not a remote:", remote.ClassName)
	end
end

function Packet.resolve(path)
	return resolvePath(path)
end

function Packet.exists(path)
	return resolvePath(path) ~= nil
end

function Packet.allowOnly(paths)
	if type(paths) == "string" then
		paths = { paths }
	end

	AllowedRoots = {}
	for _, p in ipairs(paths) do
		table.insert(AllowedRoots, string.lower(p))
	end

	dprint("allowOnly set:", table.concat(AllowedRoots, ", "))
end

function Packet.ping(path)
	local remote = resolvePath(path)
	if not remote then
		warn("[Packets] ping failed:", path)
		return false
	end

	if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
		dprint("ping ok:", path, "(" .. remote.ClassName .. ")")
		return true
	end

	warn("[Packets] ping found non-remote:", path)
	return false
end

function Packet.getVersion()
	return Packet.version or "main"
end

function Packet.isLatest()
	return Packet.version == nil or Packet.version == "main"
end

return Packet
