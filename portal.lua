local function sandport(pos)
	for i = -1,1,2 do
		for j = -1,1,2 do
			if ( minetest.get_node({x=pos.x+i, y=pos.y+2, z=pos.z+j}).name ~= "default:torch"
			     and minetest.get_node({x=pos.x+i, y=pos.y+2, z=pos.z+j}).name ~= "torches:floor" )
			or minetest.get_node({x=pos.x+i, y=pos.y+2, z=pos.z+j}).param2 ~= 1
			or minetest.get_node({x=pos.x+i, y=pos.y+1, z=pos.z+j}).name ~= "default:sand"
			or minetest.get_node({x=pos.x+i, y=pos.y, z=pos.z+j}).name ~= "default:sand" then
				return false
			end
		end
		if minetest.get_node({x=pos.x+i, y=pos.y-2, z=pos.z+i*2}).name ~= "default:mese"
		or minetest.get_node({x=pos.x+i*2, y=pos.y-2, z=pos.z+i}).name ~= "default:mese"
		or (not minetest.registered_nodes[minetest.get_node({x=pos.x+i*2, y=pos.y-1, z=pos.z}).name].walkable)
		or (not minetest.registered_nodes[minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z+i*2}).name].walkable)
		or minetest.get_node({x=pos.x+i, y=pos.y, z=pos.z}).name ~= "default:sand"
		or minetest.get_node({x=pos.x, y=pos.y, z=pos.z+i}).name ~= "default:sand"
		or minetest.get_node({x=pos.x+i*2, y=pos.y, z=pos.z}).name ~= "default:water_source"
		or minetest.get_node({x=pos.x, y=pos.y, z=pos.z+i*2}).name ~= "default:water_source" then
			return false
		end
	end
	for k = 3,4,1 do
		for i = -k,k,2*k do
			for j = -k,k,2*k do
				if ( minetest.get_node({x=pos.x+i, y=pos.y, z=pos.z+j}).name ~= "default:torch"
				     and minetest.get_node({x=pos.x+i, y=pos.y, z=pos.z+j}).name ~= "torches:floor")
				or minetest.get_node({x=pos.x+i, y=pos.y, z=pos.z+j}).param2 ~= 1 then
					return false
				end
			end
		end
		if minetest.get_node({x=pos.x, y=pos.y+k-3, z=pos.z}).name ~= "default:mese" then
			return false
		end
	end
	return true
end

local function use_sand_portal(pos)
	minetest.sound_play("nyanland_portal", {pos = pos,	gain = 0.5,	max_hear_distance = 5})
	minetest.add_particlespawner{
		amount = 300,
		time = 17,
		minpos = {x=pos.x-0.2, y=pos.y+0.5, z=pos.z-0.2},
		maxpos = {x=pos.x+0.2, y=pos.y+0.4, z=pos.z+0.2},
		minvel = {x=-0.2, y=-0, z=-0.2},
		maxvel = {x=0.2, y=0, z=0.2},
		minacc = {x=-0.5,y=4,z=-0.5},
		maxacc = {x=0.5,y=5,z=0.5},
		minexptime = 1,
		maxexptime = 10,
		minsize = 1,
		maxsize = 9,
		collisiondetection = true,
		texture = "smoke_puff.png"
	}
	minetest.after(math.random(16), function()
		local target_pos = {x=pos.x, y=pos.y + nyanland_height + 10, z=pos.z}
		local objs = minetest.get_objects_inside_radius({x=pos.x, y=pos.y+0.5, z=pos.z}, 1)
		for _, obj in pairs(objs) do
			obj:setpos(target_pos)
		end
		minetest.sound_play("nyanland_cat", {pos = target_pos,	gain = 0.9,	max_hear_distance = 35})
	end)
end

minetest.register_on_punchnode(function(pos, node, puncher)
	if puncher:get_wielded_item():get_name() == "default:stick"
	and node.name == "default:mese"	--actually not necesary
	and sandport{x=pos.x, y=pos.y-1, z=pos.z} then
		use_sand_portal(pos)
	end
end)
