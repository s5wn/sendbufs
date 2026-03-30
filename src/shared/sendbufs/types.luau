local serdes = require("./serdes")
export type ev_mt<T> = {
	fire_client: (self: t_event<T>, plr: Player, arg: T) -> (),
	fire_server: (self: t_event<T>, arg: T) -> (),
	fire_all: (self: t_event<T>, arg: T) -> (),
	connect_client: (self: t_event<T>, cb: (arg: T) -> ()) -> (),
	connect_server: (self: t_event<T>, cb: (plr: Player, arg: T) -> ()) -> (),
}

export type fn_mt<T, R...> = {
	invoke: (self: t_fn<T, R...>, arg: T) -> R...,
	set_callback: (self: t_fn<T, R...>, cb: (plr: Player, arg: T) -> R...) -> (),
}

export type fn_listener = () -> ()

export type t_event<T> = {
	listeners: { fn_listener },
	schema: serdes.serdes_data<T>,
	type: number,
	id: number,
} & ev_mt<T>

export type t_fn<T, R...> = {
	schema: serdes.serdes_data<T>,
	schema_out: serdes.serdes_data<{ any }>,
	id: number,
} & fn_mt<T, R...>

return nil
