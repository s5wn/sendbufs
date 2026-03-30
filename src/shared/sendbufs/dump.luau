local buffer_writer = require("./buffer-writer")
return @native function(b: buffer_writer.buffer_writer): (buffer, { unknown }?)
	warn(b, "DUMPING")
	local cursor = b.cursor
	local dumpBuffer = buffer.create(cursor)
	buffer.copy(dumpBuffer, 0, b.buff, 0, cursor)
	return dumpBuffer, if #b.references > 0 then b.references else nil
end
