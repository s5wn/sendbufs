local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local buffer_writer = require("./buffer-writer")

local alloc = buffer_writer.alloc
local u8 = buffer_writer.u8

local dump = require("./dump")
local read = require("./read")

@native
function create_super(): buffer_writer.buffer_writer
	return {
		size = 256,
		cursor = 0,
		buff = buffer.create(256),
		references = {},
	}
end

local payload_reliable = create_super()
local payload_unreliable = create_super()

@native
function send_reliable_packet(id: number, writer: (buf: buffer_writer.buffer_writer, data: any) -> (), data: any)
	alloc(payload_reliable, 2)
	u8(payload_reliable, id)
	writer(payload_reliable, data)
end
@native
function send_unreliable_packet(id: number, writer: (buf: buffer_writer.buffer_writer, data: any) -> (), data: any)
	alloc(payload_unreliable, 2)
	u8(payload_unreliable, id)
	writer(payload_unreliable, data)
end

@native
function start()
	print("INIT CLINET")
	local reliable: RemoteEvent = ReplicatedStorage:WaitForChild(".reliable", math.huge)
	reliable.OnClientEvent:Connect(read)
	local unreliable: UnreliableRemoteEvent = ReplicatedStorage:WaitForChild(".unreliable", math.huge)
	unreliable.OnClientEvent:Connect(read)
	local remote_fn: RemoteFunction = ReplicatedStorage:WaitForChild(".remote_fn", math.huge)

	print("here")

	RunService.Heartbeat:Connect(function()
		if payload_reliable.cursor > 0 then
			local dump, refs = dump(payload_reliable)
			reliable:FireServer(dump, refs)
			payload_reliable.cursor = 0
			table.clear(payload_reliable.references)
		end
		if payload_unreliable.cursor > 0 then
			local b, r = dump(payload_unreliable)
			unreliable:FireServer(b, r)
			payload_unreliable.cursor = 0
			table.clear(payload_unreliable.references)
		end
	end)
end

return {
	start = start,
	send_reliable_packet = send_reliable_packet,
	send_unreliable_packet = send_unreliable_packet,
}
