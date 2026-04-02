const types = require("./types")

type reflist = { types.t_event<never> | types.t_fn<never, never> }
const refs: reflist = {}
return refs
