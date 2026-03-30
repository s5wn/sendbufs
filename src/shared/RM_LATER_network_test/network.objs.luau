local sendbufs = require("@shared/sendbufs")

return {
	test = sendbufs.create_event(sendbufs.schema.ARRAY(sendbufs.schema.STRUCT({
		name = sendbufs.schema.REF,
		age = sendbufs.schema.U8,
		random_numbers = sendbufs.schema.ARRAY(sendbufs.schema.U8),
		maybe = sendbufs.schema.OPTIONAL(sendbufs.schema.BOOL),
	}))),
}
