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
		local xyz = 1
		local xz = 1
		for z=minp.z,minp.z+mgnm.mapchunk_size.z-1 do
		for y=minp.y,minp.y+mgnm.mapchunk_size.y-1 do
		for x=minp.x,minp.x+mgnm.mapchunk_size.x-1 do
			self[xyz] = t[xyz] - (y - limit[xz])
			xyz = xyz + 1
			xz = xz + 1
		end
			xz = xz - self.size.x
		end
			xz = xz + self.size.x
		end
	end,
	size = mgnm.mapchunk_size,
	dims = 3,
})

local caves = mgnm:auto{
	a = nlnoise.normalise{
		offset = 0,
		scale = 1,
		seed = 56,
		spread = {x=50,y=50,z=50},
		octaves = 4,
		persistance = 0.5,
		lacunarity = 1.5,
		size = mgnm.mapchunk_size,
		dims = 3,
	},
	b = nlnoise.normalise{
		offset = 0,
		scale = 1,
		seed = 57,
		spread = {x=50,y=50,z=50},
		octaves = 4,
		persistance = 0.5,
		lacunarity = 1.5,
		size = mgnm.mapchunk_size,
		dims = 3,
	},
	combiner = function(self, noises)
		local a = noises.a
		local b = noises.b
		local minp = self.minp
		local min = -0.05
		local max = 0.05
		local xyz = 1
		for z=1,self.size.z do
		for y=1,self.size.y do
		for x=1,self.size.x do
			if a[xyz] > min and a[xyz] < max
			and b[xyz] > min and b[xyz] < max then
				self[xyz] = true
			else
				self[xyz] = false
			end
			if a[xyz] > 1 or b[xyz] > 1 then
				self[xyz] = false
			end
			xyz = xyz + 1
		end
		end
		end
	end,
	size = mgnm.mapchunk_size,
	dims = 3,
}


local stone = minetest.get_content_id("default:stone")
local desert_stone = minetest.get_content_id("default:desert_stone")
local sand = minetest.get_content_id("default:sand")
local water = minetest.get_content_id("default:water_source")

minetest.register_on_generated(function(minp,maxp,seed)
	local v = mgnm:mg_vmanip()
	v:init()
	v:get_data()

	base:init(minp)
	mountains:init(minp)
	caves:init(minp)

	local xyz = 1
	local xz = 1

	for z=minp.z,maxp.z do
	for y=minp.y,maxp.y do
	for x=minp.x,maxp.x do
		local vmi = v:index(x,y,z)
		if caves[xyz] then
			-- v.data[vmi] = air
		elseif y < base[xz] then
			if y < 2 then
				v.data[vmi] = sand
			else
				v.data[vmi] = stone
			end
		elseif mountains:get(x,y,z) > 0 then
			v.data[vmi] = desert_stone
		elseif y < 0 then
			v.data[vmi] = water
		--else
		--	v.data[vmi] = air
		end
		xyz = xyz + 1
		xz = xz + 1
	end
		xz = xz - base.size.x
	end
		xz = xz + base.size.x
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
