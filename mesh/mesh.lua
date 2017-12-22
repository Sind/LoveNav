mesh = class()

require "mesh/triangle"
require "mesh/point"
require "mesh/persistence"

MESH_MODE = {
	POINT = 1,
	POLYGON = 2,
	DELETE = 3, 
}

POINTER_COLOR = {
	[MESH_MODE.POINT] = {0,0,255,100},
	[MESH_MODE.POLYGON] = {0, 255, 0, 100},
	[MESH_MODE.DELETE] = {0,0,0,100},
}

POINT_COLOR = {0,0,255,200}
TRIANGLE_LINE = {0,200,0,100}
TRIANGLE_FILL = {0,255,0,100}

function mesh:init()
	self.mode = MESH_MODE.POINT
	self.points = {}
	self.triangles = {}
	self.currentPolygon = {}
	self.latestPosition = {x=0,y=0}
end

function mesh:update(mouse)
	self.latestPosition = {x=mouse.x,y=mouse.y}
end

function mesh:getPointIndex(p)
	for i,v in ipairs(self.points) do
		if p == v then
			return i
		end
	end
end

function mesh:findPoint(p,distance)
	for i,v in ipairs(self.points) do
		if mesh.dist(p,v) < distance then
			return v
		end
	end
	return nil
end

function mesh:removeTriangle(t)
	for i,p in ipairs(t.points) do
		p:removeTriangle(t)
	end
	local i = self:getTriangleIndex(t)
	table.remove(self.triangles,i)
end

function mesh:removePoint(p)
	for i = #p.triangles, 1, -1 do
		t = p.triangles[i]
		self:removeTriangle(t)
	end
	local i = self:getPointIndex(p)
	table.remove(self.points,i)
end

function mesh:getTriangleIndex(t)
	for i,v in ipairs(self.triangles) do
		if t == v then
			return i
		end
	end
end


function mesh:savePolygon()
	local line = {}
	for i,v in ipairs(self.currentPolygon) do
		line[#line+1] = v[1]
		line[#line+1] = v[2]
	end
	local ts = love.math.triangulate(line)
	for i,v in ipairs(ts) do
		--one triangle
		local tr = {}
		for i = 1,5,2 do
			local px = v[i]
			local py = v[i+1]
			tr[#tr+1] = self:findPoint(point(px,py),POINT_RADIUS)
		end
		local t = triangle(tr,self)
		self.triangles[#self.triangles+1] = t
	end

end


function mesh.dist(p1,p2)
	local a = p1[1] - p2[1]
	local b = p1[2] - p2[2]
	return math.sqrt(a*a+b*b)
end

function mesh.containsPoint(l,p)
	for i,v in ipairs(l) do
		if v == p then
			return true
		end
	end
	return false
end

function mesh:draw(scale)
	love.graphics.setColor(POINT_COLOR)
	for i,p in ipairs(self.points) do
		love.graphics.circle("fill",p[1],p[2],POINT_RADIUS)
	end
	for i,t in ipairs(self.triangles) do
		t:draw()
	end
	love.graphics.setColor(POINTER_COLOR[self.mode])
	if mesh.mode == MESH_MODE.POLYGON then
		if #self.currentPolygon > 0 then
			local line = {}
			for i,v in ipairs(self.currentPolygon) do
				line[#line+1] = v[1]
				line[#line+1] = v[2]
			end
			line[#line+1] = self.latestPosition.x
			line[#line+1] = self.latestPosition.y
			love.graphics.line(line)
		end
	end
	love.graphics.circle("fill",self.latestPosition.x,self.latestPosition.y,POINT_RADIUS/scale)
	love.graphics.setColor(WHITE)
end

function mesh:mousepressed(x,y,button)
	if button == 1 then
		local newpoint = point(x,y)
		if self.mode == MESH_MODE.POINT then
			if not self:findPoint(newpoint,MIN_POINT_DISTANCE) then
				self.points[#self.points+1] = newpoint
			end
		elseif self.mode == MESH_MODE.DELETE then
			local p = self:findPoint(newpoint,POINT_HIT_DISTANCE)
			if p then
				self:removePoint(p)
				return
			end
			for i,t in ipairs(self.triangles) do
				if t:contains(newpoint) then
					self:removeTriangle(t)
				end
			end
		elseif self.mode == MESH_MODE.POLYGON then
			for i,p in ipairs(self.points) do
				if mesh.dist(p,newpoint) < POINT_HIT_DISTANCE then
					if #self.currentPolygon > 2 and p == self.currentPolygon[1] then
						self:savePolygon()
						self.currentPolygon = {}
					elseif not mesh.containsPoint(self.currentPolygon,p) then
						self.currentPolygon[#self.currentPolygon+1] = p
					end
				end
			end
		end
	end
end

function mesh:keypressed(key)
	if key == "p" or key == "b" or key == "1" then
		self.mode = MESH_MODE.POINT
	elseif key == "4" or key == "g" then
		self.mode = MESH_MODE.POLYGON
		self.currentPolygon = {}
	elseif key == "d" or key == "5" then
		self.mode = MESH_MODE.DELETE
	end
end
--saves points, format:
-- x,y
--pointers are reduced to indexes
--saves triangles,format:
-- {A,B,C},passable  -- the points are stored in counterclockwise direction

function mesh:save()
	local newpoints = {}
	local newtriangles = {}
	for i,v in ipairs(self.points) do
		newpoints[#newpoints+1] = v:simplify()
	end

	--gets triangles, without neighbor info
	for i,v in ipairs(self.triangles) do
		newtriangles[#newtriangles+1] = v:simplify()
	end
	--calculate neighbor info of triangles
	for i = 1, #newtriangles-1 do
		local u = newtriangles[i]
		for j = i+1, #newtriangles do
			local v = newtriangles[j]
			if mesh.shareEdge(u,v) then
				u.neighbors[#u.neighbors+1] = j
				v.neighbors[#v.neighbors+1] = i
			end
		end
	end
	persistence.store("level.lua", {points = newpoints, triangles = newtriangles});

end

function mesh.shareEdge(k,l)
	sharedVertexes = 0
	for i,u in ipairs(k.points) do
		for j,v in ipairs(l.points) do
			if u == v then sharedVertexes = sharedVertexes + 1 end
		end
	end
	return sharedVertexes == 2
end