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
	for i,v in ipairs(self.points) do
		tpoints[#tpoints+1] = getPointIndex(v)
	end
	return {points = tpoints, passable = (self.color == "green")}
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