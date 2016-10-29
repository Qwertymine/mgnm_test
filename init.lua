mgmini:minify({x=15,y=3,z=15})

local base = mgnm:auto({
	ln = {
		offset = -16,
		scale = 32,
		seed = 0,
		spread = {x=350,y=350,z=350},
		octaves = 6,
		persistance = 0.5,
		lacunarity = 1.5,
		flags = "absvalue",
		size = mgnm.mapchunk_size,
		dims = 2,
	},
	bn = {
		offset = 0,
		scale = 4,
		seed = 0,
		spread = {x=50,y=50,z=50},
		octaves = 3,
		persistance = 0.5,
		lacunarity = 2,
		flags = "eased",
		size = mgnm.mapchunk_size,
		dims = 2,
	},
	combiner = function(self,noises)
		for i=1,#noises.ln do
			self[i] = noises.ln[i] + noises.bn[i]
		end
	end,
	size = mgnm.mapchunk_size,
	dims = 2,
	--]]
})


local stone = minetest.get_content_id("default:stone")
local sand = minetest.get_content_id("default:sand")
local water = minetest.get_content_id("default:water_source")

minetest.register_on_generated(function(minp,maxp,seed)
	local v = mgnm:mg_vmanip()
	v:init()
	v:get_data()

	base:init(minp)
	for z=minp.z,maxp.z do
	for y=minp.y,maxp.y do
	for x=minp.x,maxp.x do
		if y < base[base:index(x,z)] then
			if y < 2 then
				v.data[v:index(x,y,z)] = sand
			else
				v.data[v:index(x,y,z)] = stone
			end
		elseif y < 0 then
			v.data[v:index(x,y,z)] = water
		end
	end
	end
	end

	v:set_data()
	v:calc_lighting()
	v:write_to_map()
	v:tini()
end)


minetest.register_on_mapgen_init(function(mgparams)
	mgparams.mgname = "singlenode"
	-- Avoid changing the mapgen seed
	mgparams.seed = nil
	mgparams.flags = mgparams.flags .. " , nolight "
	minetest.set_mapgen_params(mgparams)
end)
