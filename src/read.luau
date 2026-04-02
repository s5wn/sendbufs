const buffer_writer = require("./buffer-writer")
const fire_listeners = require("./fire-listeners")
const middleware = require("./middleware")
const remotes = require("./remotes")
const types = require("./types")

const from = buffer_writer.from

return @native function(b: buffer, refs: { unknown }?, plr: Player?)
	local cursor = 0
	const totalLen = buffer.len(b)
	const sb = from(b)
	sb.references = refs or {}
	while cursor < totalLen do
		const id = buffer.readu8(b, cursor)
		const remo = remotes[id]
		cursor += 1
		const value, nc = (remo.schema.read :: (b: types.buffer_writer, c: number) -> (never, number))(sb, cursor)
		cursor += nc
		if remo.kind == "event" and remo.listeners ~= nil then
			if plr and not middleware.run_middleware_for(id, plr, b, refs) then
				continue
			end
			fire_listeners(remo.listeners, value, plr)
		end
	end
end
