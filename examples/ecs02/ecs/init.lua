local ecs = {}


function ecs.world()
	local self = {}
	local entities = {}
	local systems = {}

	function self.get_entities(filter)
		local r = {}
		for _,e in ipairs(entities) do
			if filter(e) then
				table.insert(r, e)
			end
		end
		return r
	end

	function self.add_entity(e)
		table.insert(entities, e)
		return self
	end

	function self.remove_entity(e)
		for i,_e in ipairs(entities) do
			if _e == e then
				table.remove(entities, i)
				return self
			end
		end
	end


	function self.add_system(system)
		table.insert(systems, system(self))
		return self
	end

	function self.remove_system(name)
		for i,system in ipairs(systems) do
			if system.name == name then
				table.remove(systems, i)
				return self
			end
		end
	end

	return setmetatable(self, {__call = function (_, event, ...)
		for _,sys in ipairs(systems) do
			local handle = sys[event]
			if handle then
				handle(...)
			end
		end
	end})
end


function ecs.entity(name)
	local e = {}
	e.name = name or 'unknown'
	e.has = {}

	return setmetatable(e, {__add = function (_, f)
		local name, desc, component = f()

		assert(not e.has[name], 'repeat component '..name)
		e.has[name] = desc

		for k,v in pairs(component) do
			assert(not e[k], 'repeat key'..k)
			e[k] = v
		end
		return e
	end, __sub = function (_, name)
		local desc = assert(e.has[name], 'no component '..tostring(name))
		for _,key in ipairs(desc) do
			e[key] = nil
		end
		e.has[name] = nil
	end})
end


return ecs