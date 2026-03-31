local RunService = game:GetService("RunService")

local network_objs = require("./network.objs")


while RunService:IsRunning() do
local s,res = network_objs.test:invoke({
    age = 4,
    pos = vector.create(25.111,-10000.315135,3000000),
    pos2 = vector.create(25.1351,10000,-3000000),
    pos3 = vector.create(-1.1953150910,10000.1238591398981,3000000.1395813895891389),
    cf=CFrame.lookAlong(Vector3.one, Vector3.new(1,0,1).Unit),
    name="my lil dota",
    random_numbers={17,38}
})
print("FN R",res)
end
