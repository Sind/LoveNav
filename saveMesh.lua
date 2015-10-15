
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
	for i,v in ipairs(triangles) do
		newtriangles[#newtriangles+1] = v:simplify()
	end
	persistence.store("storage.lua", {points = newpoints, triangles = newtriangles});

end

--saves