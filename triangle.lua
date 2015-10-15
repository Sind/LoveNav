triangle = class()

function triangle:init(color,points)
	self.color = color
	self.points = points
	self.coordinates = {points[1].x,points[1].y,points[2].x,points[2].y,points[3].x,points[3].y}
	for i,v in ipairs(points) do
		v:addTriangle(self)
	end
end

function triangle:draw()
	love.graphics.setColor(TRIANGLE_FILL[self.color])
	love.graphics.polygon("line",self.coordinates)
	love.graphics.setColor(TRIANGLE_LINE[self.color])
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
	return {points = tpoints, neighbors = {}, passable = (self.color == "green")}
end

function triangle:orientation()
	local a = self.points[1]
	local b = self.points[2]
	local c = self.points[3]
	return determinant(b.x-a.x, b.y-a.y, c.x-a.x, c.y-a.y) < 0
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
