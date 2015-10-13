triangle = class()

function triangle:init(id,color,points)
	self.id = id
	self.color = color
	self.points = points
	self.coordinates = {points[1].x,points[1].y,points[2].x,points[2].y,points[3].x,points[3].y}
end

function triangle:draw()
	love.graphics.setColor(TRIANGLE_FILL[self.color])
	love.graphics.polygon("line",self.coordinates)
	love.graphics.setColor(TRIANGLE_LINE[self.color])
	love.graphics.polygon("fill",self.coordinates)
	love.graphics.setColor(WHITE)
end