local types = require("./types")
type reflist = { types.t_event<any> & types.t_fn<any, any> }
local refs: reflist = {}
return refs
