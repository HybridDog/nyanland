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
	local node_over = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name
	if node_over ~= "air"
	and node_over ~= "nyanland:clonestone" then
		minetest.add_node(pos, {name=node_over})
	end
--	nodeupdate(pos)
end

minetest.register_node("nyanland:clonestone", {
	tiles = {"nyanland_clonestone.png"},
	inventory_image = minetest.inventorycube("nyanland_clonestone.png"),
	furnace_burntime = 100,
	groups = {cracky = 1},
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

minetest.register_abm(
	{nodenames = {"nyanland:healstone"},
	interval = 1.0,
	chance = 1,
	action = function(pos)
		local objs = minetest.get_objects_inside_radius(pos, 3)
		for k, obj in pairs(objs) do
			local hp = obj:get_hp()
			if hp >= 20 then return end
			obj:set_hp(hp+2)
		end
	end,
})


local c_cloudstone = minetest.get_content_id("nyanland:cloudstone")
local c_cloudstone2 = minetest.get_content_id("nyanland:cloudstone_var")
local c_clonestone = minetest.get_content_id("nyanland:clonestone")
local c_mese_shrub = minetest.get_content_id("nyanland:mese_shrub")
local c_mese_shrub_fruits = minetest.get_content_id("nyanland:mese_shrub_fruits")
local c_cloud = minetest.get_content_id("default:cloud")

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

	local pmap1 = minetest.get_perlin_map(hole, map_lengths_xyz):get2dMap_flat(minp)
	local pmap2 = minetest.get_perlin_map(height, map_lengths_xyz):get2dMap_flat(minp)

	local num = 1
	local tab = {}

	local count = 0
	for z=minp.z, maxp.z, 1 do
		for x=minp.x, maxp.x, 1 do
			count = count+1
			local test2 = math.abs(pmap2[count])
			if test2 >= 0.2 then
				local test = math.floor(pmap1[count]*3+0.5)
				local p_addpos = area:index(x, ypse+test, z)
				local p_plantpos = area:index(x, ypse+test+1, z)
				local d_p_addpos = data[p_addpos]
				local tree_rn = pr:next(1, 1000)
				if tree_rn == 1 then
					tab[num] = {x=x, y=ypse+test, z=z}
					num = num+1
					data[p_addpos] = c_cloud
				elseif pr:next(1, 5000) == 1 then
					data[p_addpos] = c_clonestone
				elseif pr:next(1, 300) == 1 then
					data[p_addpos] = c_cloudstone2
				else
					data[p_addpos] = c_cloudstone
				end
				if tree_rn == 4 then
					if pr:next(1, 1000) == 2 then
						data[p_plantpos] = c_mese_shrub_fruits
					else
						data[p_plantpos] = c_mese_shrub
					end
				end
			end
		end
	end

	vm:set_data(data)
	--vm:set_lighting({day=0, night=0})
	--vm:calc_lighting()
	vm:update_liquids()
	vm:write_to_map()

	for _,v in ipairs(tab) do
		nyanland:grow_mesetree(v)
	end

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

function nyanland:add_nyancat(nyan_headpos)
	local nyan_tailpos={}
	minetest.add_node(nyan_headpos, {name="default:nyancat"})
	local length=math.random(4,15)
	for z=nyan_headpos.z+1, nyan_headpos.z+length, 1 do
		nyan_tailpos={x=nyan_headpos.x, y=nyan_headpos.y, z=z}
		minetest.add_node(nyan_tailpos, {name="default:nyancat_rainbow"})
	end
end

local get_volume = function(pos1, pos2)
	return (pos2.x - pos1.x + 1) * (pos2.y - pos1.y + 1) * (pos2.z - pos1.z + 1)
end

local c_tree = minetest.get_content_id("nyanland:mesetree")
local c_hls = minetest.get_content_id("nyanland:healstone")
local c_apple = minetest.get_content_id("default:apple")
local c_leaves = minetest.get_content_id("nyanland:meseleaves")
local c_air = minetest.get_content_id("air")

function nyanland:grow_mesetree(pos, generated)
	local t1 = os.clock()
	local manip = minetest.get_voxel_manip()
	local vwidth = NYANLAND_TREESIZE
	local vheight = 7+vwidth
	local emerged_pos1, emerged_pos2 = manip:read_from_map({x=pos.x-vwidth, y=pos.y, z=pos.z-vwidth},
		{x=pos.x+vwidth, y=pos.y+vheight, z=pos.z+vwidth})
	local area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})

	local nodes = manip:get_data()

	--TRUNK
	pos.y=pos.y+1
	local pr = PseudoRandom(math.abs(pos.x+pos.y*3+pos.z*5))
	local trunkpos={x=pos.x, z=pos.z}
	local tran=math.random(2)
	for y=pos.y, pos.y+4+tran do
		trunkpos.y=y
		p_trunkpos=area:index(trunkpos.x, trunkpos.y, trunkpos.z)
		if math.random(200) == 1 then
			nodes[p_trunkpos] = c_hls
		else
			nodes[p_trunkpos] = c_tree
		end
	end
	--LEAVES
	local leafpos={}
	for x=(trunkpos.x-NYANLAND_TREESIZE), (trunkpos.x+NYANLAND_TREESIZE), 1 do
		for y=(trunkpos.y-NYANLAND_TREESIZE), (trunkpos.y+NYANLAND_TREESIZE), 1 do
			for z=(trunkpos.z-NYANLAND_TREESIZE), (trunkpos.z+NYANLAND_TREESIZE), 1 do
				if (x-trunkpos.x)^2+(y-trunkpos.y)^2+(z-trunkpos.z)^2<= NYANLAND_TREESIZE^2 + NYANLAND_TREESIZE then	
					p_leafpos=area:index(x, y, z)
					if nodes[p_leafpos] == c_air then
						if pr:next(1,5) ~= 1 then
							nodes[p_leafpos] = c_leaves
						elseif pr:next(1,11) == 1 then
							nodes[p_leafpos] = c_apple
						end
					end				
				end
			end
		end
	end
	manip:set_data(nodes)
	manip:write_to_map()
	if info then
		minetest.log("info", string.format("[nyanland] a mesetree grew at ("..pos.x.."|"..pos.y.."|"..pos.z..") after: %.2fs", os.clock() - t1))
		t1 = os.clock()
	end
	if not generated then
		manip:update_map()	--calc shadows
		if info then
			minetest.log("info", string.format("[nyanland] map updated after: %.2fs", os.clock() - t1))
		end
	end
end

--MOVING NYAN CATS
minetest.register_abm(
	{nodenames = {"default:nyancat"},
	interval = 10,
	chance = 100,
	action = function(pos, node, active_object_count, active_object_count_wider)
		if pos.y>NYANLAND_HEIGHT then
			minetest.remove_node(pos)
			minetest.add_entity(pos, "nyanland:head_entity")
			minetest.sound_play("nyanland_cat", {pos = pos,	gain = 0.9,	max_hear_distance = 35})
		end
	end,
})

minetest.register_entity("nyanland:head_entity", {
	physical = false,
	visual = "sprite",
	timer=0,
	textures = {"default_nc_side.png", "default_nc_side.png", "default_nc_side.png",
		"default_nc_side.png", "default_nc_back.png", "default_nc_front.png"},
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	on_activate = function(self, staticdata)
		self.object:setvelocity({x=0, y=0, z=-2})
	end,

	on_punch = function(self, hitter)
		local mesepos=self.object:getpos()
		mesepos.y=mesepos.y-1
		minetest.add_entity(mesepos, "nyanland:mese")
	end,

	on_step = function(self, dtime)
		local pos = self.object:getpos()
		local pos = {x=math.floor(pos.x+0.5), y=math.floor(pos.y+0.5), z=math.floor(pos.z+0.5)}
		self.timer=self.timer+dtime
		if self.timer>=16 then	
			minetest.add_node(pos, {name="default:nyancat"})
			self.object:remove()
			return
		end
		if minetest.get_node(pos).name == "default:nyancat_rainbow" then	
			self.object:remove()
			return
		end
		for i = math.random(6)+18,30,1 do
			local p = {x=pos.x, y=pos.y, z=pos.z+i}
			if minetest.get_node(p).name == "default:nyancat_rainbow" then
				minetest.remove_node(p)
			end
		end
		for i = 1,5,1 do
			local p = {x=pos.x, y=pos.y, z=pos.z+i}
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
	end,
	on_step = function(self, dtime)
		self.object:setacceleration({x=0, y=-10, z=0})
		local pos = self.object:getpos()
		local bcp = {x=pos.x, y=pos.y-0.7, z=pos.z} 
		local bcn = minetest.get_node(bcp)
		--if bcn.name ~= "air" then
		--	local np = {x=bcp.x, y=bcp.y+1, z=bcp.z}
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
