local Players = game:GetService("Players")

local buffer_writer = require("./buffer-writer")
local fire_listeners = require("./fire-listeners")
local remotes = require("./remotes")

local from = buffer_writer.from

return @native function(b: buffer, refs: { unknown }?, plr: Player?)
	local cursor = 0
	local totalLen = buffer.len(b)
	local sb = from(b)
	sb.references = refs or {}
	while cursor < totalLen do
		local remo = remotes[buffer.readu8(b, cursor)]
		cursor += 1
		local value, nc = remo.schema.read(sb, cursor)
		cursor += nc
		if remo.kind=="event" and remo.listeners ~= nil then
			fire_listeners(remo.listeners, value,plr);
		end
	end
end
