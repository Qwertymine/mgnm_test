--mgmini:minify({x=5,y=3,z=5})

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

local mountains = mgnm:auto({
	height_limit = {
		offset =-10,
		scale = 38,
		seed = 3,
		spread = {x=250,y=250,z=250},
		octaves = 6,
		persistance = 0.5,
		lacunarity = 1.5,
		size = mgnm.mapchunk_size,
		dims = 2,
	},
	t_noise = {
		offset = 10,
		scale = 50,
		seed = 4,
		spread = {x=150,y=75,z=150},
		octaves = 6,
		persistance = 0.5,
		lacunarity = 1.5,
		size = mgnm.mapchunk_size,
		dims = 3,
	},
	combiner = function(self, noises)
		local t = noises.t_noise
		local limit = noises.height_limit
		local minp = self.minp
		for z=minp.z,minp.z+mgnm.mapchunk_size.z-1 do
		for y=minp.y,minp.y+mgnm.mapchunk_size.y-1 do
		for x=minp.x,minp.x+mgnm.mapchunk_size.x-1 do
			self[self:index(x,y,z)] = t[t:index(x,y,z)] - (y - limit[limit:index(x,z)])
		end
		end
		end
	end,
	size = mgnm.mapchunk_size,
	dims = 3,
})


local stone = minetest.get_content_id("default:stone")
local sand = minetest.get_content_id("default:sand")
local water = minetest.get_content_id("default:water_source")

minetest.register_on_generated(function(minp,maxp,seed)
	local v = mgnm:mg_vmanip()
	v:init()
	v:get_data()

	base:init(minp)
	mountains:init(minp)

	for z=minp.z,maxp.z do
	for y=minp.y,maxp.y do
	for x=minp.x,maxp.x do
		if y < base[base:index(x,z)] then
			if y < 2 then
				v.data[v:index(x,y,z)] = sand
			else
				v.data[v:index(x,y,z)] = stone
			end
		elseif mountains:get(x,y,z) > 0 then
			v.data[v:index(x,y,z)] = sand
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
