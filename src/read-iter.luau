const buffer_writer = require("./buffer-writer")

const remotes = require("./remotes")

const from = buffer_writer.from

@native
function read_iter(reader_prop: "schema" | "schema_out", b: buffer, refs: { unknown }?)
	local cursor = 0
	const totalLen = buffer.len(b)
	const sb = from(b)
	sb.references = refs or {}
	return function()
		if cursor >= totalLen then
			return
		end
		const rid = buffer.readu8(b, cursor)
		const remo = remotes[rid]
		cursor += 1
		const value, nc = remo[reader_prop].read(sb, cursor)
		cursor += nc
		return rid, value
	end
end

return (
	read_iter :: never
) :: <T...>(reader_prop: "schema" | "schema_out", b: buffer, refs: { unknown }?) -> () -> (number, any)
