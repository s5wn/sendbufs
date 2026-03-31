local sendbufs = require("@shared/sendbufs")

return {
	test = sendbufs.create_request((sendbufs.schema.STRUCT({
		name = sendbufs.schema.STRING,
		pos = sendbufs.schema.VECI16,
		pos2 = sendbufs.schema.VECI32,
		pos3 = sendbufs.schema.VECF32,
		cf = sendbufs.schema.CFRAME,
		age = sendbufs.schema.U8,
		random_numbers = sendbufs.schema.ARRAY(sendbufs.schema.U8),
		maybe = sendbufs.schema.OPTIONAL(sendbufs.schema.BOOL),
	})), sendbufs.schema.BOOL),
}
