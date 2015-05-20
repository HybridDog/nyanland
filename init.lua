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
	inventory_image = minetest.inventorycube("nyanland_cloudstone.png"),
	use_texture_alpha = true,
	sunlight_propagates = true,
	light_source = 10,
	groups = {dig_immediate = 3},
	sounds = cloudstone_sounds
})

minetest.register_node("nyanland:cloudstone_var", {
	tiles = {"nyanland_cloudstone_var.png", "nyanland_cloudstone_var.png", "nyanland_cloudstone.png"},
	inventory_image = minetest.inventorycube("nyanland_cloudstone_var.png"),
	use_texture_alpha = true,
	sunlight_propagates = true,
	drop = '',
	light_source = 10,
	groups = {dig_immediate = 3},
	sounds = cloudstone_sounds
})


minetest.register_node("nyanland:mesetree", {
	description = "Mese Tree",
	tiles = {"nyanland_mesetree_top.png", "nyanland_mesetree_top.png", "nyanland_mesetree.png"},
	groups = {tree=1,cracky=1,level=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("nyanland:meseleaves", {
	drawtype = "allfaces_optional",
	tiles = {"nyanland_meseleaves.png"},
	inventory_image = minetest.inventorycube("nyanland_meseleaves.png"),
	paramtype = "light",
	furnace_burntime = 5,
	groups = {snappy=3, flammable=2},
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
	groups = {snappy=3,flammable=3,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
	},
})

minetest.register_node("nyanland:mese_shrub_fruits", {
	description = "Mese Shrub with fruits",
	drawtype = "plantlike",
	tiles = {"nyanland_mese_shrub_fruits.png"},
	inventory_image = "nyanland_mese_shrub_fruits.png",
	wield_image = "nyanland_mese_shrub_fruits.png",
	paramtype = "light",
	waving = 1,
	walkable = false,
	buildable_to = true,
	groups = {snappy=3,flammable=3,attached_node=1},
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
	tiles = {"nyanland_clonestone.png"},
	inventory_image = minetest.inventorycube("nyanland_clonestone.png"),
	furnace_burntime = 100,
	groups = {cracky = 1},
	on_construct = clone_node,
})

minetest.register_abm({
	nodenames = {"nyanland:clonestone"},
	interval = 5,
	chance = 1,
	action = function(pos)
		clone_node(pos)
	end,
})

-- Healstone
minetest.register_node("nyanland:healstone", {
	description = "nyanland:healstone",
	tiles = {"nyanland_healstone.png"},
	inventory_image = minetest.inventorycube("nyanland_healstone.png"),
	furnace_burntime = 100,
	groups = {cracky = 1},
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
	local n = x/(16*SIZE)
	local y = 0
	for k=1,depth do
		y = y + SIZE*(math.sin(math.pi * k^a * n)/(math.pi * k^a))
	end
	return y
end

local chunksize = minetest.setting_get("chunksize") or 5
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

local c_cloudstone = minetest.get_content_id("nyanland:cloudstone")
local c_cloudstone2 = minetest.get_content_id("nyanland:cloudstone_var")
local c_clonestone = minetest.get_content_id("nyanland:clonestone")
local c_mese_shrub = minetest.get_content_id("nyanland:mese_shrub")
local c_mese_shrub_fruits = minetest.get_content_id("nyanland:mese_shrub_fruits")
local c_cloud = minetest.get_content_id("default:cloud")
local c_mese = minetest.get_content_id("default:mese")
local c_ice = minetest.get_content_id("default:ice")

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

	if info then
		t1 = os.clock()
		local geninfo = "[nyanland] generates: x=["..minp.x.."; "..maxp.x.."]; y=["..minp.y.."; "..maxp.y.."]; z=["..minp.z.."; "..maxp.z.."]"
		minetest.log("info", geninfo)
		minetest.chat_send_all(geninfo)
	end
	local pr = PseudoRandom(seed+112)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

	local side_length = maxp.x - minp.x + 1
	local map_lengths_xyz = {x=side_length, y=side_length, z=side_length}

	local pmap1 = minetest.get_perlin_map(hole, map_lengths_xyz):get2dMap_flat({x=minp.x, y=minp.z})
	local pmap2 = minetest.get_perlin_map(height, map_lengths_xyz):get2dMap_flat({x=minp.x, y=minp.z})
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
	minetest.add_node(pos, {name="default:nyancat"})
	local length = math.random(4,15)
	for _ = 1, length do
		pos.z = pos.z+1
		minetest.add_node(pos, {name="default:nyancat_rainbow"})
	end
end

local c_tree = minetest.get_content_id("nyanland:mesetree")
local c_hls = minetest.get_content_id("nyanland:healstone")
local c_apple = minetest.get_content_id("default:apple")
local c_leaves = minetest.get_content_id("nyanland:meseleaves")
local c_air = minetest.get_content_id("air")
local c_ignore = minetest.get_content_id("ignore")

local function mesetree(pos, tran, nodes, area, pr)
	-- stem
	local head_y = pos.y+4+tran
	for y = pos.y, head_y do
		p = area:index(pos.x, y, pos.z)
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
	nodenames = {"default:nyancat"},
	interval = 10,
	chance = 100,
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
	visual = "sprite",
	timer=0,
	lastpos = {x=0, y=0, z=0},
	textures = {"default_nc_side.png", "default_nc_side.png", "default_nc_side.png",
		"default_nc_side.png", "default_nc_back.png", "default_nc_front.png"},
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	on_activate = function(self, staticdata)
		self.object:setvelocity({x=0, y=0, z=-2})
		self.lastpos = vector.round(self.object:getpos())
	end,

	on_punch = function(self, hitter)
		local mesepos=self.object:getpos()
		mesepos.y=mesepos.y-1
		minetest.add_entity(mesepos, "nyanland:mese")
	end,

	on_step = function(self, dtime)
		self.timer = self.timer+dtime
		if self.timer >= 16 then	
			minetest.add_node(self.lastpos, {name="default:nyancat"})
			self.object:remove()
			return
		end
		local pos = vector.round(self.object:getpos())
		if vector.equals(self.lastpos, pos) then
			return
		end
		self.lastpos = pos
		if minetest.get_node(pos).name == "default:nyancat_rainbow" then	
			self.object:remove()
			return
		end
		local p = vector.new(pos)
		for i = math.random(6)+18,300 do
			p.z = pos.z+i
			if minetest.get_node(p).name == "default:nyancat_rainbow" then
				minetest.remove_node(p)
			else
				break
			end
		end
		for i = 1,6 do
			p.z = pos.z+i
			if minetest.get_node(p).name == "air" then
				minetest.add_node(p, {name="default:nyancat_rainbow"})
			else
				return
			end
		end
	end
})

minetest.register_entity("nyanland:tail_entity", {
	physical = false,
	visual = "sprite",
	timer=0,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	on_step = function(self)
		self.object:remove()
	end
})

minetest.register_entity("nyanland:mese", {
	physical = true,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	textures = {"default_mese_block.png", "default_mese_block.png", "default_mese_block.png", "default_mese_block.png", "default_mese_block.png", "default_mese_block.png"},
	on_activate = function(self)
		self.object:setvelocity({x=0, y=-.1, z =0})
		self.object:setacceleration({x=0, y=-9, z=0})
	end,
	on_step = function(self, dtime)
		--[[local pos = self.object:getpos()
		local bcp = {x=pos.x, y=pos.y-0.7, z=pos.z} 
		local bcn = minetest.get_node(bcp)
		--if bcn.name ~= "air" then
		--	local np = {x=bcp.x, y=bcp.y+1, z=bcp.z}--]]
		if self.object:getvelocity().y == 0 then
			minetest.add_node(self.object:getpos(), {name="default:mese_block"})
			self.object:remove()
		end
		--	
		--end
	end
})

dofile(minetest.get_modpath("nyanland").."/portal.lua")
minetest.log("info", string.format("[nyanland] loaded after ca. %.2fs", os.clock() - load_time_start))
