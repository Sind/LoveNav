point = class()

function point:init(x,y)
	self.x = x
	self.y = y
	self.neighbors = {}
end

function point:resetNeighbors()
	self.neighbors = {}
end

function point:addNeighbor(n)
	if not self:containsNeighbor(n) then
		self.neighbors[#self.neighbors+1] = n
	end
end

function point:containsNeighbor(n)
	for i,v in ipairs(self.neighbors) do
		if samePoint(n,v) then return true end
	end
	return false
end

function point:simplify()
	local simplePoint = {x = self.x, y = self.y, neighbors = {}}
	for i,v in ipairs(self.neighbors) do
		simplePoint.neighbors[#simplePoint.neighbors+1] = getPointIndex(v)
	end
	return simplePoint

end

function getPointIndex(point)
	for i,v in ipairs(points) do
		if samePoint(point,v) then
			return i
		end
	end
end

function samePoint(a,b)
	return (a.x == b.x and a.y == b.y)
end