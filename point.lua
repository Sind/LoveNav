point = class()

function point:init(id,x,y)
	self.id = id
	self.x = x
	self.y = y
	self.neighbors = {}
end

function point:addNeighbor(n)
	if not self:containsNeighbor(n) then
		self.neighbors[#self.neighbors+1] = n
	end
end

function point:containsNeighbor(n)
	for i,v in ipairs(self.neighbors) do
		if v == n then return true end
	end
	return false
end