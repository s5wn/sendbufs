
const RunService = game:GetService("RunService")

const serdes = require("@self/serdes")

const is_server = RunService:IsServer()

const server = require("@self/server-lifecycle")
const client = require("@self/client-lifecycle")
const remotes = require("@self/remotes")
const metatables = require("@self/metatables")
const constants = require("@self/constants")
const middleware = require("@self/middleware")
const types = require("@self/types")

export type TEvent<T = never> = types.t_event<T>
export type TFunction<T = never, R = never> = types.t_fn<T, R>
export type TReplicated<T = never, R = never> = types.t_event<T> | types.t_fn<T, R>

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

function create_event<T>(t: T): TEvent<T>
	return add(setmetatable({
		kind = "event",
		listeners = {},
		schema = t,
		type = constants.EVENT_TYPE.RELIABLE,
		id = take_next(),
	}, if is_server then metatables.server_remote_metatable else metatables.client_remote_metatable)) :: never
end

function create_unreliable<T>(t: T): TEvent<T>
	return add(setmetatable({
		kind = "event",
		listeners = {},
		schema = t,
		type = constants.EVENT_TYPE.UNRELIABLE,
		id = take_next(),
	}, if is_server then metatables.server_remote_metatable else metatables.client_remote_metatable) :: never)
end

function create_request<T, R>(input: T, output: R): TFunction<T, R>
	return add(setmetatable({
		callback = nil,
		kind = "function",
		schema = input,
		schema_out = output,
		id = take_next(),
	}, if is_server then metatables.server_function_metatable else metatables.client_function_metatable) :: never)
end

if is_server then
	server.start()
else
	client.start()
end

return table.freeze({
	create_event = create_event,
	create_unreliable = create_unreliable,
	create_request = create_request,
	middleware = middleware.middleware :: <T, R>(
		evt: TReplicated<T, R>,
		fn: (id: number, plr: Player, b: buffer, refs: { unknown }?) -> boolean
	) -> (),
	global_middleware = middleware.global_middleware :: (fn: (id: number, plr: Player, b: buffer, refs: { unknown }?) -> boolean) -> (),
	schema = serdes,
})
