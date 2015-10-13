
--saves points, format:
-- x,y,{neighbors}
--pointers are reduced to indexes
--saves triangles,format:
-- {A,B,C},passable

function saveMesh()
	for i,v in ipairs(points) do
		v:resetNeighbors()
	end
	local newtriangles = {}
	for i,v in ipairs(triangles) do
		if v.color == "green" then v:pairNeighbors() end
		newtriangles[#newtriangles+1] = v:simplify()
	end
	local newpoints = {}
	for i,v in ipairs(points) do
		newpoints[#newpoints+1] = v:simplify()
	end
	persistence.store("storage.lua", {points = newpoints, triangles = newtriangles});

end

--saves