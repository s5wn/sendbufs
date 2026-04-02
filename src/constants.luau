const EVENT_TYPE = table.freeze({
	RELIABLE = 0,
	UNRELIABLE = 1,
})

const FUNCTION_STATUS = table.freeze({
	IN_PROGRESS = 2,
	PASS = 1,
	FAIL = 0,
})

return {
	EVENT_TYPE = EVENT_TYPE,
	FUNCTION_STATUS = FUNCTION_STATUS,
}
