local types = require("./types")
return function(listeners: { types.fn_listener }, ...)
	local s = #listeners
	for i = 1, s do
		task.defer(listeners[i], ...)
	end
end
