
local network_objs = require("./network.objs")
warn("INIT SERVER",getmetatable(network_objs.test),network_objs.test);
network_objs.test:set_callback(function(arg, plr: Player?)
    warn"INIT CALLBACK";
    task.wait(3);
    print("rec",arg)
    return math.random(0,1)==1;
end)