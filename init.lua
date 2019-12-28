-- Wand of Illumination [wand_of_illumination]
-- by David G (kestral246@gmail.com)
-- 2019-12-28

-- Provides a wand that when used lights up an entire room, but only for a moment.

local brightness_value = 9  -- How bright to make lights.
local MAX_DIST_SQUARED = 15^2  -- Radius of sphere (squared).
local maxcount = 15000		-- Maximum number of nodes to check.
local mana_cost = 100

local using_mana = false
if minetest.get_modpath("mana") ~= nil then
	using_mana = true
end

local scanned = {}			-- Set containing scanned nodes, so they don't get scanned multiple times.
local tocheck = {}			-- Table of nodes to check.
local tolight = {}			-- Table of nodes that need to be converted to fill lights.

minetest.register_on_joinplayer(function(player)
	local pname = player:get_player_name()
	scanned[pname] = {}
	tocheck[pname] = {}
	tolight[pname] = {}
end)

minetest.register_on_leaveplayer(function(player)
	local pname = player:get_player_name()
	scanned[pname] = nil
	tocheck[pname] = nil
	tolight[pname] = nil
end)

local mana_check = function(player, cost)
	local allowed
	if using_mana then
		if mana.subtract(player:get_player_name(), cost) then
			allowed = true
		else
			allowed = false
		end
	else
		allowed = true
	end
	return allowed
end

minetest.register_node("wand_of_illumination:light", {
	description = "Wand of Illumination Light",
	drawtype = "airlike",
	walkable = false,
	paramtype = "light",
	sunlight_propagates = true,
	light_source = brightness_value,
	pointable = false,
	buildable_to = true,
	drops = "",
	groups = {cracky = 3, oddly_breakable_by_hand = 3, fill_hidden = 1, not_in_creative_inventory = 1},
})

minetest.register_abm({
	nodenames = {"wand_of_illumination:light"},
	interval = 2.0,  -- need to tune
	chance = 10,  -- need to tune
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.set_node(pos, {name = "air"})
	end
})

-- Determine number of elements in table, for summary output.
local tlength = function(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

local square = function(x)
	return x * x
end

-- Scan neighboring nodes, flag for checking if air.
local scan_node = function(pname, pos, origin, maxdist2)
	-- Add y to test, so make search pattern a sphere
	if square(pos.x - origin.x) + square(pos.y - origin.y) + square(pos.z - origin.z) <= maxdist2 then
		local enc_pos = minetest.hash_node_position(pos)
		if scanned[pname][enc_pos] ~= true then  -- hasn't been scanned
			local name = minetest.get_node(pos).name
			if name == "air" then  -- checkable
				table.insert(tocheck[pname], enc_pos)  -- add to check list
			end
			scanned[pname][enc_pos] = true  -- don't scan again
		end
	end
end

-- To check, scan all neighbors and determine if this node needs to be converted to light.
local check_node = function(pname, pos, origin, maxdist2)
	local enc_pos = minetest.hash_node_position(pos)
	local name = minetest.get_node(pos).name
	scan_node(pname, vector.add(pos, {x=0,y=0,z=1}), origin, maxdist2)  -- north
	scan_node(pname, vector.add(pos, {x=1,y=0,z=0}), origin, maxdist2)  -- east
	scan_node(pname, vector.add(pos, {x=0,y=0,z=-1}), origin, maxdist2)  -- south
	scan_node(pname, vector.add(pos, {x=-1,y=0,z=0}), origin, maxdist2)  -- west
	scan_node(pname, vector.add(pos, {x=0,y=-1,z=0}), origin, maxdist2)  -- down
	scan_node(pname, vector.add(pos, {x=0,y=1,z=0}), origin, maxdist2)  -- up
	if name == "air" and ((pos.x%4 == 0 and pos.y%8 == 0 and pos.z%4 == 0) or
			(pos.x%4 == 2 and pos.y%8 == 4 and pos.z%4 == 2)) then
		table.insert(tolight[pname], enc_pos)
	end
end

local use_wand = function(pname, pos)
	-- Initialize temporary tables for safety.
	scanned[pname] = {}
	tocheck[pname] = {}
	tolight[pname] = {}
	-- Search starts at wand position.
	table.insert(tocheck[pname], minetest.hash_node_position(pos))
	local count = 1
	while count <= table.getn(tocheck[pname]) and count <= maxcount do
		check_node(pname, minetest.get_position_from_hash(tocheck[pname][count]),
			pos, MAX_DIST_SQUARED)  -- fifo
		count = count + 1
	end
	count = count - 1 
	local toadd = tlength(tolight[pname])
	-- Print statistics.
	--minetest.debug("wand_of_illumination: y = "..tostring(pos.y)..", scan = "..
	--		tostring(tlength(scanned[pname]))..", check = "..tostring(count)..", lights = "..
	--		tostring(tlength(tolight[pname])))
	-- Add lights to all locations flagged for lighting.
	for _,v in ipairs(tolight[pname]) do
		local fpos = minetest.get_position_from_hash(v)
		minetest.set_node(fpos, {name="wand_of_illumination:light"})
	end
	-- Clear temporary tables, which could be large.
	scanned[pname] = {}
	tocheck[pname] = {}
	tolight[pname] = {}
end

minetest.register_tool("wand_of_illumination:wand", {
	description = "Wand of Illumination",
	inventory_image = "wand_of_illumination.png",
	stack_max = 1,
	on_place = function(itemstack, player, pointed_thing)
		local pname = player:get_player_name()
		local pos = vector.add(vector.round(player:get_pos()), {x=0,y=1,z=0})  -- position of wand
		if mana_check(player, mana_cost) then
			use_wand(pname, pos)
		end
	end,
	on_secondary_use = function(itemstack, player, pointed_thing)
		local pname = player:get_player_name()
		local pos = vector.add(vector.round(player:get_pos()), {x=0,y=1,z=0})  -- position of wand
		if mana_check(player, mana_cost) then
			use_wand(pname, pos)
		end
	end,
})
