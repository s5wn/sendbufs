local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local serdes = require("@self/serdes")

local is_server = RunService:IsServer()

local server = require("@self/server-lifecycle.luau")
local client = require("@self/client-lifecycle")
local remotes = require("@self/remotes")
local types = require("@self/types")

do
	local globalid = 0

	function take_next()
		globalid += 1
		return globalid
	end
	function add<T>(t: T): T
		remotes[globalid] = t :: never
		return t
	end
end

local EVENT_TYPE = table.freeze({
	RELIABLE = 0,
	UNRELIABLE = 1,
})

local event_mt = {}
event_mt.__index = event_mt

local fn_mt = {}
fn_mt.__index = fn_mt

function to_player_table(t: Player | { Player }): { Player }
	if typeof(t) == "table" then
		return t
	end
	return { t }
end

do
	function event_mt.fire_from_server(self: types.t_event<any>, plr: Player | { Player }, ...): ()
		local plr = to_player_table(plr)
		local write_fn = self.schema.write
		local fn = if self.type == EVENT_TYPE.RELIABLE then server.send_reliable_packet else server.send_reliable_packet
		for _, plr in plr do
			(fn :: never)(plr, self.id, write_fn, ...)
		end
	end
	function event_mt.fire_from_client(self: types.t_event<any>, ...) end
	function event_mt.fire_all(self: types.t_event<any>, ...)
		local plrs = Players:GetPlayers()
		local write_fn = self.schema.write
		local fn = if self.type == EVENT_TYPE.RELIABLE
			then server.send_reliable_packet
			else server.send_unreliable_packet
		for _, plr in plrs do
			(fn :: never)(plr, self.id, write_fn, ...)
		end
	end

	function connect_listener(listeners: { types.fn_listener }, fn: (...any) -> ())
		table.insert(listeners, fn)
		return function()
			local i = table.find(listeners, fn)
			if i ~= nil then
				table.remove(listeners, i)
			end
		end
	end
	function event_mt.connect_client(self: types.t_event<any>, cb: () -> ())
		return connect_listener(self.listeners, cb)
	end
	event_mt.connect_server = event_mt.connect_client

	table.freeze(event_mt)
end

do
	function fn_mt.set_callback<T>(self: types.t_fn<any>, cb: (plr: Player, ...any) -> ...any) end
	function fn_mt.invoke<T>(self: types.t_fn<any>, ...) end
	table.freeze(fn_mt)
end

function create_event<T>(t: T): types.t_event<T>
	return add(setmetatable({
		listeners = {},
		schema = t,
		type = EVENT_TYPE.RELIABLE,
		id = take_next(),
	}, event_mt) :: never)
end

function create_unreliable<T>(t: T): types.t_event<T>
	return add(setmetatable({
		listeners = {},
		schema = t,
		type = EVENT_TYPE.UNRELIABLE,
		id = take_next(),
	}, event_mt) :: never)
end

function create_query<T, R...>(input: T, ...: R...): types.t_fn<T, R...>
	return add(setmetatable({
		listeners = {},
		schema = input,
		schema_out = select(1, ...) :: { any },
		id = take_next(),
	}, {}) :: never)
end

if is_server then
	server.start()
else
	client.start()
end

return table.freeze({
	create_event = create_event,
	create_unreliable = create_unreliable,
	create_query = create_query,
	schema = serdes,
})
