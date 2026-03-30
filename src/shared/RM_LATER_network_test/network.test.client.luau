local network_objs = require("./network.objs")

local d = network_objs.test:connect_client(function(data)
	--print(data, "HI")
end)
