local network_objs = require("./network.objs")

while task.wait(1) do
	network_objs.test:fire_all(table.create(1, {
		name = "Joshanthan",
		age = 21,
		random_numbers = { 12, 2, 4, 12, 4 },
		maybe = if math.random(0, 1) == 1 then true else nil,
	}))
end
