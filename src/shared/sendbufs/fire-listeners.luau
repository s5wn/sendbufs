local types = require("./types")
return function(listeners: { types.fn_listener }, ...)
	local s = #listeners
	for i = 1, s do
		local r = listeners[i];
		if (r.once) then
			table.remove(listeners,i);
		end
		warn(r.fn,'exists')
		task.defer(r.fn, ...)
	end
end
