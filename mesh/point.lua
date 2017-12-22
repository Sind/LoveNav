point = class()

function point:init(x,y, mesh)
	self.mesh = mesh
	self[1] = x
	self[2] = y
	self.triangles = {}
end


function point:addTriangle(t)
	self.triangles[#self.triangles+1] = t
end

-- function point:remove()
-- 	for i = #self.triangles,1,-1 do
-- 		self.triangles[i]:remove()
-- 	end
-- 	local i = getPointIndex(self)
-- 	table.remove(self.mesh.points,i)
-- end

function point:removeTriangle(t)
	for i,v in ipairs(self.triangles) do
		if v == t then
			table.remove(self.triangles,i)
		end
	end
end

function point:simplify()
	local simplePoint = {x = self[1], y = self[2]}
	return simplePoint
end

point:setmetamethod("__eq",
	function (a,b)
		return (a[1] == b[1] and b[2] == b[2])
	end
)

function determinant(x1,y1,x2,y2)
	return x1*y2 - x2*y1
end