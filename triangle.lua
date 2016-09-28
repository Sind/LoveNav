triangle = class()

function triangle:init(points)
	self.points = points
	self.coordinates = {points[1][1],points[1][2],points[2][1],points[2][2],points[3][1],points[3][2]}
	for i,v in ipairs(points) do
		v:addTriangle(self)
	end
end

function triangle:draw()
	love.graphics.setColor(TRIANGLE_FILL)
	love.graphics.polygon("line",self.coordinates)
	love.graphics.setColor(TRIANGLE_LINE)
	love.graphics.polygon("fill",self.coordinates)
	love.graphics.setColor(WHITE)
end

function triangle:simplify()
	local tpoints = {}
	local a = getPointIndex(self.points[1])
	local b = getPointIndex(self.points[2])
	local c = getPointIndex(self.points[3])
	if self:orientation() then
		tpoints = {a,b,c}
	else
		tpoints = {a,c,b}
	end
	return {points = tpoints, neighbors = {}}
end

function triangle:orientation()
	local a = self.points[1]
	local b = self.points[2]
	local c = self.points[3]
	return determinant(b[1]-a[1], b[2]-a[2], c[1]-a[1], c[2]-a[2]) < 0
end

function triangle:contains(x,y)
	local a = self.points[1]
	local b = self.points[2]
	local c = self.points[3]
	local ad = determinant(b[1]-a[1],b[2]-a[2],x-a[1],y-a[2])
	local bd = determinant(c[1]-b[1],c[2]-b[2],x-b[1],y-b[2])
	local cd = determinant(a[1]-c[1],a[2]-c[2],x-c[1],y-c[2])
	local adb = (ad < 0)
	local bdb = (bd < 0)
	local cdb = (cd < 0)
	return (adb and bdb and cdb) or (not (adb or bdb or cdb))
end

function triangle:remove()
	for i,v in ipairs(self.points) do
		v:removeTriangle(self)
	end
	local i = getTriangleIndex(self)
	table.remove(triangles,i)
end

function getTriangleIndex(triangle)
	for i,v in ipairs(triangles) do
		if sameTriangle(triangle, v) then
			return i
		end
	end
end

function sameTriangle(a,b)
	return (samePoint(a.points[1],b.points[1]) and samePoint(a.points[2],b.points[2]) and samePoint(a.points[3],b.points[3]))
end
