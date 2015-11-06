
--saves points, format:
-- x,y
--pointers are reduced to indexes
--saves triangles,format:
-- {A,B,C},passable  -- the points are stored in counterclockwise direction

function saveMesh()
	local newpoints = {}
	local newtriangles = {}
	for i,v in ipairs(points) do
		newpoints[#newpoints+1] = v:simplify()
	end

	--gets triangles, without neighbor info
	for i,v in ipairs(triangles) do
		newtriangles[#newtriangles+1] = v:simplify()
	end
	--calculate neighbor info of triangles
	for i = 1, #newtriangles-1 do
		local u = newtriangles[i]
		if u.passable then
			for j = i+1, #newtriangles do
				local v = newtriangles[j]
				if v.passable then
					if shareEdge(u,v) then
						u.neighbors[#u.neighbors+1] = j
						v.neighbors[#v.neighbors+1] = i
					end
				end
			end
		end
	end
	persistence.store("level.lua", {points = newpoints, triangles = newtriangles});

end

function shareEdge(k,l)
	sharedVertexes = 0
	for i,u in ipairs(k.points) do
		for j,v in ipairs(l.points) do
			if u == v then sharedVertexes = sharedVertexes + 1 end
		end
	end
	return sharedVertexes == 2
end