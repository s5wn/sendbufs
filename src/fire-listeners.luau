const types = require("./types")
return function(listeners: { types.fn_listener }, ...)
	const s = #listeners
	for i = 1, s do
		const r = listeners[i]
		if r == nil then
			break
		end
		if r.once then
			table.remove(listeners, i)
		end
		task.defer(r.fn, ...)
	end
end
