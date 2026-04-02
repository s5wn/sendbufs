const types = require("./types")
return @native function(b: types.buffer_writer): (buffer, { unknown }?)
	const cursor = b.cursor
	const dumpBuffer = buffer.create(cursor)
	buffer.copy(dumpBuffer, 0, b.buff, 0, cursor)
	return dumpBuffer, if #b.references > 0 then b.references else nil
end
