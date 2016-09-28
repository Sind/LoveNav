vertex = class()
triangle = class()
path = class()
navmesh = class()

function vertex:init(point)
	self.x = point.x
	self.y = point.y
end

function vertex.determinant(x1,y1,x2,y2)
	return x1*y2 - x2*y1
end

function pequal(a,b)
	return a[1] == b[1] and a[2] == b[2]
end

function triarea(a,b,c)
	local ax = b[1] - a[1]
	local ay = b[2] - a[2]
	local bx = c[1] - a[1]
	local by = c[2] - a[2]
	local ans = vertex.determinant(bx,by,ax,ay)
	print("ans", ans)
	return ans
end


function triangle:init(navmesh,primitiveTriangle)
	self.navmesh = navmesh
	self.vertexes = primitiveTriangle.points
	local a = navmesh.vertexes[self.vertexes[1]]
	local b = navmesh.vertexes[self.vertexes[2]]
	local c = navmesh.vertexes[self.vertexes[3]]
	self.center = {x = (a.x+b.x+c.x)/3, y = (a.y+b.y+c.y)/3}
	self.neighbors = primitiveTriangle.neighbors
	self.passable = true
	self.edges = {}
end

function triangle:contains(x,y)
	local a = self.navmesh.vertexes[self.vertexes[1]]
	local b = self.navmesh.vertexes[self.vertexes[2]]
	local c = self.navmesh.vertexes[self.vertexes[3]]
	local ad = vertex.determinant(b.x-a.x,b.y-a.y,x-a.x,y-a.y)
	local bd = vertex.determinant(c.x-b.x,c.y-b.y,x-b.x,y-b.y)
	local cd = vertex.determinant(a.x-c.x,a.y-c.y,x-c.x,y-c.y)
	local adb = (ad < 0)
	local bdb = (bd < 0)
	local cdb = (cd < 0)
	return adb and bdb and cdb
end

function triangle:calculateEdges()
	for i,v in ipairs(self.neighbors) do
		self.edges[i] = navmesh.dist(self.center,self.navmesh.triangles[v].center)
	end
end

function path:init()
	self.points = {}
	self.length = 0
	self.poistion = 0
end

function path:addPoint(p)
	self.points[#self.points+1] = p
	if #self.points == 1 then return end
	-- local ydist = self.points[#self.points]
	-- local dist = math.sqrt(xdist*xdist + ydist*ydist)
	-- self.length =  self.length + dist
end

function path:move(dist)
	self.position = self.position + dist
	if self.position >= self.length then
		return self.points[#self.points], true
	end
	local realPosition = 2 --TODO: calculate position 
	return realPosition, false
end

function path:draw()
	love.graphics.setColor(128, 128, 128, 255)
	for i = 2, #self.points do
		local s = self.points[i-1]
		local e = self.points[i]
		love.graphics.line(s[1], s[2], e[1], e[2])
	end
	love.graphics.setColor(255, 255, 255, 255)
end


function navmesh:init(map)
	self.vertexes = {}
	self.triangles = {}
	for i,v in ipairs(map.points) do
		self.vertexes[i] = vertex:new(v)
	end
	for i,v in ipairs(map.triangles) do
		local t = triangle:new(self,v)
		self.triangles[i] = t
	end
	for i,v in ipairs(self.triangles) do
		v:calculateEdges()
	end
	self.speed = 100
end

function navmesh:setSpeed(n)
	self.speed = n
end

function navmesh:findTriangle(x,y)
	for i,v in ipairs(self.triangles) do
		if v:contains(x,y) then
			return i
		end
	end
	return nil
end

function navmesh:findPath(x1,y1,x2,y2)
	coarsePath = self:findCoarsePath(x1,y1,x2,y2)
	if not coarsePath then return nil end
	local portals = self:getPortals(x1,y1,x2,y2,coarsePath)
	local tpath = self:funnel(portals)
	-- local path = self
	print("path")
	for i,v in ipairs(tpath.points) do
		print(v[1], v[2])
	end
	print("endpath")
	return portals, tpath
end

function navmesh:findCoarsePath(x1,y1,x2,y2)
	local start = self:findTriangle(x1,y1)
	local stop = self:findTriangle(x2,y2)
	if (start == nil) or (stop == nil) then return nil end
	local stopCenter = {x = x2, y = y2}
	local currentCenter = self.triangles[start].center
	local open = {{i = start,G = 0, H = navmesh.hdist(currentCenter,stopCenter), F = navmesh.hdist(currentCenter,stopCenter)}}
	local closed = {}
	while true do
		currentItem = open[1]
		if #open > 1 then
			for i = 2,#open do
				if open[i].F < currentItem.F then
					currentItem = open[i]
				end
			end
		end
		for i,v in ipairs(open) do
			if currentItem.i == v.i then
				table.remove(open,i)
				break
			end
		end
		closed[#closed+1] = currentItem
		if currentItem.i == stop then
			local coarsePath = {currentItem.i}
			if currentItem.i == start then return coarsePath end
			while true do
				for i,v in ipairs(closed) do
					if v.i == currentItem.parent then
						currentItem = v
						break
					end
				end
				coarsePath[#coarsePath+1] = currentItem.i
				if currentItem.i == start then return coarsePath end
			end
		end
		local currentTriangle = self.triangles[currentItem.i]
		local neighbors = currentTriangle.neighbors
		local edges = currentTriangle.edges
		for i,v in ipairs(neighbors) do
			local isclosed = false
			for j,u in ipairs(closed) do
				if v == u.i then
					isclosed = true
					break
				end
			end
			if not isclosed then
				local index = nil
				for j,u in ipairs(open) do
					if u.i == v then
						index = j
						break
					end
				end
				if not index then
					local item = {}
					item.i = v
					item.G = currentItem.G + edges[i]
					item.H = navmesh.hdist(self.triangles[v].center,stopCenter)
					item.F = item.G + item.H
					item.parent = currentItem.i
					open[#open+1] = item
				else
					local G = currentItem.G + edges[i]
					local item = open[index]
					if G < item.G then
						item.parent = currentItem.i
						item.G = G
						item.F = item.H + G
					end
				end
			end
		end
	end
end

function navmesh:getPortals(x1,y1,x2,y2,coarsePath)
	local currentTriangle = coarsePath[1]
	local portals = {{x2,y2},{x2,y2}}
	for i = 2, #coarsePath do
		nextTriangle = coarsePath[i]
		local p1,p2 = self:getPortal(currentTriangle,nextTriangle)
		portals[#portals+1] = {self.vertexes[p1].x,self.vertexes[p1].y}
		portals[#portals+1] = {self.vertexes[p2].x,self.vertexes[p2].y}
		currentTriangle = nextTriangle
	end
	portals[#portals+1] = {x1,y1}
	portals[#portals+1] = {x1,y1}

	return portals
end

function navmesh:getPortal(t1,t2)
	st1 = self.triangles[t1]
	st2 = self.triangles[t2]
	for i,v in ipairs(st1.vertexes) do
		for j,u in ipairs(st2.vertexes) do
			if u == v then
				local previ = ((i-1) == 0 and 3 or i-1)
				local nextj = ((j+1) == 4 and 1 or j+1)
				if st1.vertexes[previ] == st2.vertexes[nextj] then
					return v,st1.vertexes[previ]
				end 
			end
		end
	end
end

function navmesh:funnel(portals)
	local truePath = path:new()
	for i,v in ipairs(portals) do 
		print("portal", i,v[1],v[2])
	end

	local apexIndex = 1
	local leftIndex = 1
	local rightIdex = 1

	local apex = portals[1]
	local left = portals[1]
	local right = portals[2]

	truePath:addPoint(apex)

	local i = 2

	while i <= #portals/2 do
		nleft = portals[i*2-1]
		nright = portals[i*2]


		skip = false
		if triarea(apex,right,nright) >= 0 then
			if pequal(apex,right) or triarea(apex,left,nright) < 0 then
				right = nright
				rightIndex = i
			else
				--left is new  apex
				truePath:addPoint(left)
				apexIndex = leftIndex
				apex = left

				left = apex
				right = apex
				leftIndex = apexIndex
				rightIndex = apexIndex
				i = apexIndex

				skip = true
			end
		end
		if not skip then 
			if triarea(apex,left,nleft) <= 0 then
				if pequal(apex,left) or triarea(apex,right,nleft) > 0 then
					left = nleft
					leftIndex = i
				else
					--right is new  apex
					truePath:addPoint(right)
					apexIndex = rightIndex
					apex = right

					leftIndex = apexIndex
					rightIndex = apexIndex
					left = apex
					right = apex
					i = apexIndex
				end
			end
		end

		i = i+1
	end
	truePath:addPoint(portals[#portals])
	return truePath
end

function navmesh:draw()
	for i,v in ipairs(self.triangles) do
		if v.passable then
			if coarsePath and table.getIndex(coarsePath,i) then
				love.graphics.setColor(355, 355, 0, 100)
			else
				love.graphics.setColor(0, 255, 0, 100)
			end
			local a = self.vertexes[v.vertexes[1]]
			local b = self.vertexes[v.vertexes[2]]
			local c = self.vertexes[v.vertexes[3]]
			local line = {a.x,a.y,b.x,b.y,c.x,c.y}
			love.graphics.polygon("fill", line)
			love.graphics.polygon("line", line)
		end
	end
	love.graphics.setColor(255, 255, 255, 255)
end

function navmesh.hdist(a,b)
	local x = math.abs(a.x-b.x)
	local y = math.abs(a.y-b.y)
	return x+y
end

function navmesh.dist(a,b)
	local x = b.x - a.x
	local y = b.y - a.y
	return math.sqrt(x*x+y*y)
end

function table.getIndex(t,v)
	for i,u in ipairs(t) do
		if v == u then return i end
	end
	return nil
end

