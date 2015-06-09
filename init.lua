-- simple nixie tubes mod
-- by Vanessa Ezekowitz

nixie_tubes = {}

local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end

local nixie_types = {
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"0",
	"colon",
	"period",
	"off"
}

local tube_cbox = {
	type = "fixed",
	fixed = { -4/16, -8/16, -4/16, 4/16, 2/16, 4/16 }
}

-- the following functions based on the so-named ones in Jeija's digilines mod

local reset_meta = function(pos)
	minetest.get_meta(pos):set_string("formspec", "field[channel;Channel;${channel}]")
end

local on_digiline_receive = function(pos, node, channel, msg)
	local meta = minetest.get_meta(pos)
	local setchan = meta:get_string("channel")
	if setchan ~= channel then return end
	local num = tonumber(msg)
	if msg == "colon" or msg == "period" or msg == "off" or (num >= 0 and num <= 9) then
		minetest.swap_node(pos, { name = "nixie_tubes:tube_"..msg, param2 = node.param2})
	end
end

-- the nodes:

for _,tube in ipairs(nixie_types) do
	local groups = { cracky = 2, not_in_creative_inventory = 1}
	local light = LIGHT_MAX-4
	local description = S("Nixie Tube ("..tube..")")
	local cathode = "nixie_tube_cathode_off.png^nixie_tube_cathode_"..tube..".png"

	if tube == "off" then
		groups = {cracky = 2}
		light = nil
		description = S("Nixie Tube")
		cathode = "nixie_tube_cathode_off.png"
	end

	minetest.register_node("nixie_tubes:tube_"..tube, {
		description = description,
		drawtype = "mesh",
		mesh = "nixie_tube.obj",
		tiles = {
			"nixie_tube_base.png",
			"nixie_tube_backing.png",
			cathode,
			"nixie_tube_anode.png",
			"nixie_tube_glass.png",
		},
		use_texture_alpha = true,
		groups = groups,
		paramtype = "light",
		paramtype2 = "facedir",
		light_source = light,
		selection_box = tube_cbox,
		collision_box = tube_cbox,
		on_construct = function(pos)
			reset_meta(pos)
		end,
		on_receive_fields = function(pos, formname, fields, sender)
			if (fields.channel) then
				minetest.get_meta(pos):set_string("channel", fields.channel)
			end
		end,
		digiline = {
			receptor = {},
			effector = {
				action = on_digiline_receive
			},
		},
		drop = "nixie_tubes:tube_off"
	})
end


