local load_time_start = os.clock()

NYANLAND_HEIGHT=30688
NYANCAT_PROP=1
NYANLAND_TREESIZE=2
local info = minetest.is_singleplayer()

local nyanland={}

--Cloudstone
local cloudstone_sounds = {
	dug = {name="default_dug_node", gain=0.25},
	place = {name="default_place_node_hard", gain=0.1},
	footstep = {name="nyanland_cloud_footstep", gain=0.05}
}

minetest.register_node("nyanland:cloudstone", {
	tiles = {"nyanland_cloudstone.png"},
	use_texture_alpha = true,
	sunlight_propagates = true,
	light_source = 10,
	groups = {dig_immediate = 3, not_in_creative_inventory=1},
	sounds = cloudstone_sounds
})

minetest.register_node("nyanland:cloudstone_var", {
	tiles = {"nyanland_cloudstone_var.png", "nyanland_cloudstone_var.png", "nyanland_cloudstone.png"},
	use_texture_alpha = true,
	sunlight_propagates = true,
	drop = '',
	light_source = 10,
	groups = {dig_immediate = 3, not_in_creative_inventory=1},
	sounds = cloudstone_sounds
})


minetest.register_node("nyanland:mesetree", {
	description = "Mese Tree",
	tiles = {"nyanland_mesetree_top.png", "nyanland_mesetree_top.png", "nyanland_mesetree.png"},
	groups = {tree=1,cracky=1,level=2, not_in_creative_inventory=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("nyanland:meseleaves", {
	drawtype = "allfaces_optional",
	tiles = {"nyanland_meseleaves.png"},
	paramtype = "light",
	furnace_burntime = 5,
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1},
--	groups = {snappy=3, leafdecay=3, flammable=2},
})

minetest.register_node("nyanland:mese_shrub", {
	description = "Mese Shrub",
	drawtype = "plantlike",
	tiles = {"nyanland_mese_shrub.png"},
	inventory_image = "nyanland_mese_shrub.png",
	wield_image = "nyanland_mese_shrub.png",
	paramtype = "light",
	waving = 1,
	walkable = false,
	buildable_to = true,
	groups = {snappy=3,flammable=3,attached_node=1, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
	},
})

minetest.register_node("nyanland:mese_shrub_fruits", {
	description = "Mese Shrub with fruits",
	drawtype = "plantlike",
	tiles = {"nyanland_mese_shrub.png^nyanland_mese_shrub_fruits.png"},
	inventory_image = "nyanland_mese_shrub.png^nyanland_mese_shrub_fruits.png",
	wield_image = "nyanland_mese_shrub.png^nyanland_mese_shrub_fruits.png",
	paramtype = "light",
	waving = 1,
	walkable = false,
	buildable_to = true,
	groups = {snappy=3,flammable=3,attached_node=1, not_in_creative_inventory=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
	},
})

-- Clonestone
local function clone_node(pos)
	pos.y = pos.y+1
	local nd = minetest.get_node(pos)
	local node_over = nd.name
	if node_over ~= "air"
	and node_over ~= "ignore"
	and node_over ~= "nyanland:clonestone"
	and minetest.registered_nodes[node_over] then
		local metacontent = minetest.get_meta(pos):to_table()
		pos.y = pos.y-1
		minetest.add_node(pos, nd)
		minetest.get_meta(pos):from_table(metacontent)
	end
--	nodeupdate(pos)
end

minetest.register_node("nyanland:clonestone", {
	description = "clonestone",
	tiles = {"nyanland_clonestone.png"},
	furnace_burntime = 100,
	groups = {cracky = 1, not_in_creative_inventory=1},
	on_construct = clone_node,
})

minetest.register_abm({
	nodenames = {"nyanland:clonestone"},
	interval = 5,
	chance = 1,
	catch_up = false,
	action = function(pos)
		clone_node(pos)
	end,
})

-- Healstone
minetest.register_node("nyanland:healstone", {
	description = "nyanland healstone",
	tiles = {"nyanland_healstone.png"},
	furnace_burntime = 100,
	groups = {cracky = 1, not_in_creative_inventory=1},
})

minetest.register_abm({
	nodenames = {"nyanland:healstone"},
	interval = 1.0,
	chance = 1,
	action = function(pos)
		for _, obj in pairs(minetest.get_objects_inside_radius(pos, 3)) do
			local hp = obj:get_hp()
			if hp >= 20 then return end
			obj:set_hp(hp+2)
		end
	end,
})


-- Weierstrass function stuff from https://github.com/slemonide/gen
local SIZE = 1000
local ssize = math.ceil(math.abs(SIZE))
local function do_ws_func(depth, a, x)
	local n = math.pi * x / (16 * SIZE)
	local y = 0
	for k = 1,depth do
		y = y + math.sin(k^a * n) / k^a
	end
	return SIZE * y / math.pi
end

local chunksize = minetest.setting_get"chunksize" or 5
local ws_lists = {}
local function get_ws_list(a,x)
	ws_lists[a] = ws_lists[a] or {}
	local v = ws_lists[a][x]
	if v then
			return v
	end
	v = {}
	for x=x,x + (chunksize*16 - 1) do
	local y = do_ws_func(ssize, a, x)
			v[x] = y
	end
	ws_lists[a][x] = v
	return v
end


local generate_mesetree

local c_cloudstone = minetest.get_content_id"nyanland:cloudstone"
local c_cloudstone2 = minetest.get_content_id"nyanland:cloudstone_var"
local c_clonestone = minetest.get_content_id"nyanland:clonestone"
local c_mese_shrub = minetest.get_content_id"nyanland:mese_shrub"
local c_mese_shrub_fruits = minetest.get_content_id"nyanland:mese_shrub_fruits"
local c_cloud = minetest.get_content_id"default:cloud"
local c_mese = minetest.get_content_id"default:mese"
local c_ice = minetest.get_content_id"default:ice"

local ypse = NYANLAND_HEIGHT

local hole = {
	seed = 13,
	octaves = 3,
	persist = 0.5,
	spread = {x=500, y=500, z=500},
	scale = 1,
	offset = 0,
}

local height = {
	seed = 133,
	octaves = 3,
	persist = 0.5,
	spread = {x=100, y=100, z=100},
	scale = 1,
	offset = 0,
}


minetest.register_on_generated(function(minp, maxp, seed)
	if (minp.y >= ypse+10 or maxp.y <= ypse-10) then
		return
	end

	local t1
	if info then
		t1 = os.clock()
		local geninfo = "[nyanland] generates: x=["..minp.x.."; "..maxp.x.."]; y=["..minp.y.."; "..maxp.y.."]; z=["..minp.z.."; "..maxp.z.."]"
		minetest.log("info", geninfo)
		minetest.chat_send_all(geninfo)
	end
	local pr = PseudoRandom(seed+112)
	local vm, emin, emax = minetest.get_mapgen_object"voxelmanip"
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

	local side_length = maxp.x - minp.x + 1
	local map_lengths_xyz = {x=side_length, y=side_length, z=side_length}

	local pmap1 = minetest.get_perlin_map(hole, map_lengths_xyz):get2dMap_flat{x=minp.x, y=minp.z}
	local pmap2 = minetest.get_perlin_map(height, map_lengths_xyz):get2dMap_flat{x=minp.x, y=minp.z}
	local strassx = get_ws_list(3, minp.x)
	local strassz = get_ws_list(5, minp.z)
	local strassnx = get_ws_list(2, minp.x)
	local strassnz = get_ws_list(2, minp.z)

	local num = 1
	local tab = {}

	local count = 0
	for z=minp.z, maxp.z do
		for x=minp.x, maxp.x do
			count = count+1
			local test2 = math.abs(pmap2[count])
			if test2 >= 0.2 then
				local y = ypse + math.floor(pmap1[count]*3+0.5)
				if y <= maxp.y
				and y >= minp.y then
					local depth = math.floor(((strassx[x]+strassz[z])%14)*math.min((test2-0.2)*25/4, 1)+0.5)
					if depth ~= 0 then
						local sel = math.floor(strassnx[x]+strassnz[z]+0.5)%10
						local p = area:index(x, y-depth, z)
						if sel <= 5 then
							data[p] = c_cloudstone
						elseif sel == 6 then
							data[p] = c_ice
						elseif sel == 7 then
							data[p] = c_mese
						end
					end
					local p = area:index(x, y, z)
					local tree_rn = pr:next(1, 1000)
					if tree_rn == 1 then
						tab[num] = {x=x, y=y+1, z=z}
						num = num+1
						data[p] = c_cloud
					elseif pr:next(1, 5000) == 1 then
						data[p] = c_clonestone
					elseif pr:next(1, 300) == 1 then
						data[p] = c_cloudstone2
					else
						data[p] = c_cloudstone
					end
					if tree_rn == 4 then
						local p = area:index(x, y+1, z)
						if pr:next(1, 1000) == 2 then
							data[p] = c_mese_shrub_fruits
						else
							data[p] = c_mese_shrub
						end
					end
				end
			end
		end
	end

	for _,p in pairs(tab) do
		generate_mesetree(p, data, area, pr)
	end

	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	--vm:update_liquids()
	vm:write_to_map()

	if math.random(NYANCAT_PROP)==1 then
		local nyan_headpos={}
		nyan_headpos={x=minp.x+pr:next(1, 80), y=ypse+pr:next(1, 20)+10, z=minp.z+pr:next(1, 80)}
		nyanland:add_nyancat(nyan_headpos, minp)
	end
	if info then
		local geninfo = string.format("[nyanland] done after: %.2fs", os.clock() - t1)
		minetest.log("info", geninfo)
		minetest.chat_send_all(geninfo)
	end
end)

function nyanland:add_nyancat(pos)
	minetest.add_node(pos, {name="nyancat:nyancat"})
	local length = math.random(4,15)
	for _ = 1, length do
		pos.z = pos.z+1
		minetest.add_node(pos, {name="nyancat:nyancat_rainbow"})
	end
end

local c_tree = minetest.get_content_id"nyanland:mesetree"
local c_hls = minetest.get_content_id"nyanland:healstone"
local c_apple = minetest.get_content_id"default:apple"
local c_leaves = minetest.get_content_id"nyanland:meseleaves"
local c_air = minetest.get_content_id"air"
local c_ignore = minetest.get_content_id"ignore"

local function mesetree(pos, tran, nodes, area, pr)
	-- stem
	local head_y = pos.y+4+tran
	for y = pos.y, head_y do
		local p = area:index(pos.x, y, pos.z)
		if pr:next(1,200) == 1 then
			nodes[p] = c_hls
		else
			nodes[p] = c_tree
		end
	end
	-- head
	local s = NYANLAND_TREESIZE
	for x = -s, s do
		for y = -s, s do
			for z = -s, s do
				if x*x + y*y + z*z <= s*s + s then
					local p = area:index(pos.x+x, head_y+y, pos.z+z)
					if nodes[p] == c_air
					or nodes[p] == c_ignore then
						if pr:next(1,5) ~= 1 then
							nodes[p] = c_leaves
						elseif pr:next(1,11) == 1 then
							nodes[p] = c_apple
						end
					end
				end
			end
		end
	end
end

function generate_mesetree(pos, nodes, area, pr)
	mesetree(pos, pr:next(1,2), nodes, area, pr)
end

--[[function nyanland:grow_mesetree(pos)
	local t1 = os.clock()

	local manip = minetest.get_voxel_manip()
	local vwidth = NYANLAND_TREESIZE
	local vheight = 7+vwidth
	local emerged_pos1, emerged_pos2 = manip:read_from_map({x=pos.x-vwidth, y=pos.y, z=pos.z-vwidth},
		{x=pos.x+vwidth, y=pos.y+vheight, z=pos.z+vwidth})
	local area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
	local nodes = manip:get_data()

	local pr = PseudoRandom(math.abs(pos.x+pos.y*3+pos.z*5))

	mesetree(pos, pr:next(1,2), nodes, area, pr)

	manip:set_data(nodes)
	manip:write_to_map()
	if info then
		minetest.log("info", string.format("[nyanland] a mesetree grew at ("..pos.x.."|"..pos.y.."|"..pos.z..") after: %.2fs", os.clock() - t1))
		t1 = os.clock()
	end
	manip:update_map()	--calc shadows
	if info then
		minetest.log("info", string.format("[nyanland] map updated after: %.2fs", os.clock() - t1))
	end
end]]

--MOVING NYAN CATS
minetest.register_abm({
	nodenames = {"nyancat:nyancat"},
	interval = 10,
	chance = 100,
	catch_up = false,
	action = function(pos)
		if pos.y > NYANLAND_HEIGHT then
			minetest.remove_node(pos)
			minetest.add_entity(pos, "nyanland:head_entity")
			minetest.sound_play("nyanland_cat", {pos = pos,	gain = 0.9, max_hear_distance = 35})
		end
	end,
})

minetest.register_entity("nyanland:head_entity", {
	physical = true,
	lastpos = {x=0, y=0, z=0},
	textures = {"nyancat_side.png", "nyancat_side.png", "nyancat_side.png",
		"nyancat_side.png", "nyancat_back.png", "nyancat_front.png"},
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	visual_size = {x=1.001, y=1.001},
	on_activate = function(self)
		self.object:setvelocity{x=0, y=0, z=-2}
		self.object:set_armor_groups{immortal=1}
		self.lastpos = vector.round(self.object:getpos())
		self.timer = math.random()*8-4
	end,

	on_punch = function(self)
		local mesepos = self.object:getpos()
		if math.random(10) == 1 then
			minetest.sound_play("nyanland_cat", {pos = mesepos,	gain = 0.9, max_hear_distance = 35})
		end
		mesepos.y = mesepos.y-1
		spawn_falling_node(mesepos, {name = "default:mese_block"})
	end,

	on_step = function(self, dtime)
		self.timer = self.timer+dtime
		if self.timer >= 16 then
			minetest.add_node(self.lastpos, {name="nyancat:nyancat"})
			self.object:remove()
			return
		end
		local finepos = self.object:getpos()
		local pos = vector.round(finepos)
		if vector.equals(self.lastpos, pos) then
			return
		end
		self.lastpos = pos
		if minetest.get_node(pos).name == "nyancat:nyancat_rainbow" then
			self.object:remove()
			return
		end
		local p = vector.new(pos)
		for i = math.random(6)+18,300 do
			p.z = pos.z+i
			if minetest.get_node(p).name ~= "nyancat:nyancat_rainbow" then
				break
			end
			minetest.remove_node(p)
		end
		local z = math.floor(finepos.z+0.1)
		for i = 1,6 do
			p.z = z+i
			if minetest.get_node(p).name ~= "air" then
				return
			end
			minetest.add_node(p, {name="nyancat:nyancat_rainbow"})
		end
	end
})


local nt = {
	"[combine:32x16:0,0=nyancat_rainbow.png^[transformFX^[combine:32x16:0,0=nyancat_rainbow.png^[transformR90",
	"[combine:16x32:0,0=nyancat_rainbow.png^[transformFX^[combine:16x32:0,16=nyancat_rainbow.png"
}

for i = 1,2 do
	nt[2*i-1] = {
		name = nt[i],
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 0.6,	-- 300ms (from nyan.cat)
		}
	}
end

nt[2] = nt[1]

minetest.override_item("nyancat:nyancat_rainbow", {tiles = nt})


minetest.register_node("nyanland:nyancat", {
	description = "golden Nyan Cat",
	tiles = {"nyancat_side.png", "nyancat_side.png", "nyancat_side.png",
		"nyancat_side.png", "default_gold_block.png^nyanland_nc_back.png", "default_gold_block.png^nyanland_nc_front.png"},
	paramtype2 = "facedir",
	groups = {cracky=1, not_in_creative_inventory=1},
	is_ground_content = false,
	legacy_facedir_simple = true,
	sounds = default.node_sound_defaults(),
	after_place_node = function(pos, player)
		minetest.get_meta(pos):set_string("owner", player:get_player_name())
	end,
	can_dig = function(pos, player)
		local owner = minetest.get_meta(pos):get_string"owner"
		return not owner
			or owner == ""
			or (
				owner == player:get_player_name()
				and player:get_player_control().sneak
			)
	end,
})

local punchfct = minetest.registered_nodes["nyanland:nyancat"].on_punch
minetest.override_item("nyanland:nyancat", {
	on_punch = function(pos, node, player, pt, ...)
		if pt.above
		and minetest.get_meta(pos):get_string"owner" == player:get_player_name()
		and not player:get_player_control().sneak
		and minetest.get_node(pt.above).name == "air" then
			minetest.sound_play("nyanland_cat", {pos = pos,	gain = 2, max_hear_distance = 41})
			minetest.set_node(pt.above, {name="default:goldblock"})
		end
		return punchfct(pos, node, player, pt, ...)
	end,
})

local makecat = nyancat.place
function nyancat.place(pos, facedir, length)
	if minetest.get_node(pos).name ~= "default:stone_with_gold" then
		return makecat(pos, facedir, length)
	end
	local tailvec = minetest.facedir_to_dir(facedir)
	local p = vector.new(pos)
	minetest.set_node(p, {name = "nyanland:nyancat", param2 = facedir})
	for i = 1, length+5 do
		p.x = p.x + tailvec.x
		p.z = p.z + tailvec.z
		minetest.set_node(p, {name = "nyancat:nyancat_rainbow", param2 = facedir})
	end
end


dofile(minetest.get_modpath"nyanland".."/portal.lua")


-- legacy

minetest.register_entity("nyanland:tail_entity", {
	--[[physical = false,
	visual = "sprite",
	timer=0,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",--]]
	on_activate = function(self)
		self.object:remove()
	end
})

minetest.register_entity("nyanland:mese", {
	on_activate = function(self)
		self.object:remove()
	end,
})


minetest.log("info", string.format("[nyanland] loaded after ca. %.2fs", os.clock() - load_time_start))
