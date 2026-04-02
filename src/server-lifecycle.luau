const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")

const remotes = require("./remotes")
const read_iter = require("./read-iter")
const read = require("./read")
const buffer_writer = require("./buffer-writer")

const alloc = buffer_writer.alloc
const u8 = buffer_writer.u8

const dump = require("./dump")
const logger = require("./logger")
const middleware = require("./middleware")
const types = require("./types")
const validate_buffer = require("./validate-buffer")

@native
function create_super(): types.buffer_writer
	return {
		size = 256,
		cursor = 0,
		buff = buffer.create(256),
		references = {},
	}
end

const mt = { __mode = "k" }

const players_reliable: { [Player]: types.buffer_writer? } = {}
const players_unreliable: { [Player]: types.buffer_writer? } = {}

setmetatable(players_reliable, mt)
setmetatable(players_unreliable, mt)

@native
function send_reliable_packet(to: Player, id: number, writer: (buf: types.buffer_writer, data: any) -> (), data: any)
	const buf = players_reliable[to] or create_super()
	alloc(buf, 2)
	u8(buf, id)
	writer(buf, data)
	players_reliable[to] = buf
end
@native
function send_unreliable_packet(to: Player, id: number, writer: (buf: types.buffer_writer, data: any) -> (), data: any)
	const buf = players_unreliable[to] or create_super()
	alloc(buf, 2)
	u8(buf, id)
	writer(buf, data)
	players_unreliable[to] = buf
end

@native
function start()
	const reliable = Instance.new("RemoteEvent")
	reliable.Name = ".reliable"
	const unreliable = Instance.new("UnreliableRemoteEvent")
	unreliable.Name = ".unreliable"
	const remote_fn = Instance.new("RemoteFunction")
	remote_fn.Name = ".remote_fn"

	remote_fn.OnServerInvoke = function(plr, b, ref)
		logger.errorif(not validate_buffer(b, ref), "INVALID BUFFER")
		for nid, val in read_iter("schema", b) do
			if not middleware.run_middleware_for(nid, plr, b, ref) then
				continue
			end
			const rm = remotes[nid]
			if rm == nil or rm.kind ~= "function" then
				logger.orange("INVALID FUNCTION")
				return false
			end
			const rm: types.t_fn<any, any> = rm
			const success, res = pcall(rm.callback :: never, val, plr)
			if not success then
				return false
			end
			const buf = create_super()
			rm.schema_out.write(buf, res)
			const r, refs = dump(buf)
			return true, r, refs
		end
		logger.orange("INVALID ID")
		return false
	end

	reliable.OnServerEvent:Connect(function(plr: Player, b, r)
		logger.errorif(not validate_buffer(b, r), "INVALID BUFFER")
		read(b, r, plr)
	end)
	unreliable.OnServerEvent:Connect(function(plr: Player, b, r)
		logger.errorif(not validate_buffer(b, r), "INVALID BUFFER")
		read(b, r, plr)
	end)

	reliable.Parent = ReplicatedStorage
	unreliable.Parent = ReplicatedStorage
	remote_fn.Parent = ReplicatedStorage

	RunService.Heartbeat:Connect(function()
		for _, plr in Players:GetPlayers() do
			do
				const buf = players_reliable[plr]
				if buf ~= nil and buf.cursor > 0 then
					const dumpBuffer, references = dump(buf)
					reliable:FireClient(plr, dumpBuffer, references)
					buf.cursor = 0
					table.clear(buf.references)
				end
			end
			do
				const buf = players_unreliable[plr]
				if buf ~= nil and buf.cursor > 0 then
					const dumpBuffer, references = dump(buf)
					unreliable:FireClient(plr, dumpBuffer, references)
					buf.cursor = 0
					table.clear(buf.references)
				end
			end
		end
	end)
end

return {
	start = start,
	send_reliable_packet = send_reliable_packet,
	send_unreliable_packet = send_unreliable_packet,
}
