--- Implementation of Log4g.
-- @license Apache License 2.0
-- @copyright GrayWolf64

--- A simple OOP library for Lua which has inheritance, metamethods, class variables and weak mixin support.
local function initMiddleClass()
	local MiddleClass = {}
	local type = type

	local function _createIndexWrapper(aClass, f)
		if f == nil then
			return aClass.__instanceDict
		elseif type(f) == "function" then
			return function(self, name)
				local value = aClass.__instanceDict[name]

				if value ~= nil then
					return value
				else
					return f(self, name)
				end
			end
		else
			return function(self, name)
				local value = aClass.__instanceDict[name]

				if value ~= nil then
					return value
				else
					return f[name]
				end
			end
		end
	end

	local function _propagateInstanceMethod(aClass, name, f)
		f = name == "__index" and _createIndexWrapper(aClass, f) or f
		aClass.__instanceDict[name] = f

		for subclass in pairs(aClass.subclasses) do
			if rawget(subclass.__declaredMethods, name) == nil then
				_propagateInstanceMethod(subclass, name, f)
			end
		end
	end

	local function _declareInstanceMethod(aClass, name, f)
		aClass.__declaredMethods[name] = f

		if f == nil and aClass.super then
			f = aClass.super.__instanceDict[name]
		end

		_propagateInstanceMethod(aClass, name, f)
	end

	local function _tostring(self)
		return "class " .. self.name
	end

	local function _call(self, ...)
		return self:New(...)
	end

	local function _createClass(name, super)
		local dict = {}
		dict.__index = dict

		local aClass = {
			name = name,
			super = super,
			static = {},
			__instanceDict = dict,
			__declaredMethods = {},
			subclasses = setmetatable({}, {
				__mode = "k",
			}),
		}

		if super then
			setmetatable(aClass.static, {
				__index = function(_, k)
					local result = rawget(dict, k)
					if result == nil then
						return super.static[k]
					end

					return result
				end,
			})
		else
			setmetatable(aClass.static, {
				__index = function(_, k)
					return rawget(dict, k)
				end,
			})
		end

		setmetatable(aClass, {
			__index = aClass.static,
			__tostring = _tostring,
			__call = _call,
			__newindex = _declareInstanceMethod,
		})

		return aClass
	end

	local function _includeMixin(aClass, mixin)
		if type(mixin) ~= "table" then
			return
		end

		for name, method in pairs(mixin) do
			if name ~= "included" and name ~= "static" then
				aClass[name] = method
			end
		end

		for name, method in pairs(mixin.static or {}) do
			aClass.static[name] = method
		end

		if type(mixin.included) == "function" then
			mixin:included(aClass)
		end

		return aClass
	end

	local DefaultMixin = {
		__tostring = function(self)
			return "instance of " .. tostring(self.class)
		end,
		Initialize = function(self, ...) end,
		isInstanceOf = function(self, aClass)
			return type(aClass) == "table"
				and type(self) == "table"
				and (
					self.class == aClass
					or type(self.class) == "table"
						and type(self.class.isSubclassOf) == "function"
						and self.class:isSubclassOf(aClass)
				)
		end,
		static = {
			allocate = function(self)
				if type(self) ~= "table" then
					return
				end

				return setmetatable({
					class = self,
				}, self.__instanceDict)
			end,
			New = function(self, ...)
				if type(self) ~= "table" then
					return
				end
				local instance = self:allocate()
				instance:Initialize(...)

				return instance
			end,
			subclass = function(self, name)
				if type(self) ~= "table" or type(name) ~= "string" then
					return
				end
				local subclass = _createClass(name, self)

				for methodName, f in pairs(self.__instanceDict) do
					if not (methodName == "__index" and type(f) == "table") then
						_propagateInstanceMethod(subclass, methodName, f)
					end
				end

				subclass.Initialize = function(instance, ...)
					return self.Initialize(instance, ...)
				end
				self.subclasses[subclass] = true
				self:subclassed(subclass)

				return subclass
			end,
			subclassed = function(self, other) end,
			isSubclassOf = function(self, other)
				return type(other) == "table"
					and type(self.super) == "table"
					and (self.super == other or self.super:isSubclassOf(other))
			end,
			include = function(self, ...)
				if type(self) ~= "table" then
					return
				end

				for _, mixin in ipairs({ ... }) do
					_includeMixin(self, mixin)
				end

				return self
			end,
		},
	}

	function MiddleClass.class(name, super)
		if type(name) ~= "string" then
			return
		end

		return super and super:subclass(name) or _includeMixin(_createClass(name), DefaultMixin)
	end

	setmetatable(MiddleClass, {
		__call = function(_, ...)
			return MiddleClass.class(...)
		end,
	})

	return MiddleClass
end

local MiddleClass = initMiddleClass()
--- Class Object is the root of the class hierarchy.
local function initObject()
	local tableConcat = table.concat
	local Object = MiddleClass("Object")

	--- A table for storing private properties of an object.
	-- @local
	-- @table Private
	local Private = Private or setmetatable({}, {
		__mode = "k",
	})

	--- When an Object is initialized, a private field(sub table) in the `PRIVATE` table will be dedicated to it based on `self` key.
	function Object:Initialize()
		Private[self] = {}
	end

	function Object:__tostring()
		return "Object: [name:" .. self:GetName() .. "]"
	end

	--- Sets the name of the Object.
	-- @param name String name
	function Object:SetName(name)
		if type(name) ~= "string" then
			return
		end
		Private[self].name = name
	end

	--- Gets the name of the Object.
	-- @return string name
	function Object:GetName()
		return Private[self].name
	end

	--- Sets a private field for the Object.
	-- @param key Of any type except nil
	-- @param value Of any type except nil
	function Object:SetPrivateField(key, value)
		if not key or not value then
			return
		end
		Private[self][key] = value
	end

	--- Gets a private field of the Object.
	-- @param key Of any type except nil
	-- @return anytype private value
	function Object:GetPrivateField(key)
		if not key then
			return
		end

		return Private[self][key]
	end

	--- Destroys its private table.
	function Object:DestroyPrivateTable()
		Private[self] = nil
	end

	--- Removes the dot extension of a string.
	-- @param str String
	-- @param doconcat Whether `table.concat` the result
	-- @return string result
	local function stripDotExtension(str, doconcat)
		if type(str) ~= "string" then
			return
		end

		--- Optimized version of [string.Explode](https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/extensions/string.lua#L87-L104).
		local function stringExplode(separator, string)
			local result, currentPos = {}, 1

			for i = 1, #string do
				local startPos, endPos = string:find(separator, currentPos, true)
				if not startPos then
					break
				end
				result[i], currentPos = string:sub(currentPos, startPos - 1), endPos + 1
			end

			result[#result + 1] = string:sub(currentPos)

			return result
		end

		local result = stringExplode(".", str:sub(1, #str - str:reverse():find("%.")))

		if doconcat ~= false then
			return tableConcat(result, ".")
		else
			return result
		end
	end

	--- Generate all the ancestors' names of a LoggerConfig or something else.
	-- The provided name must follow [Named Hierarchy](https://logging.apache.org/log4j/2.x/manual/architecture.html).
	-- @param name Object's name
	-- @return table ancestors' names in a list-styled table
	-- @return table parent name but with dots removed in a table
	local function enumerateAncestors(name)
		local nodes, ancestors, s = stripDotExtension(name, false), {}, ""

		for k, v in ipairs(nodes) do
			if k ~= 1 then
				s = s .. "." .. v
			else
				s = s .. v
			end

			ancestors[s] = true
		end

		return ancestors, nodes
	end

	--- Get and Set Context functions minxin.
	-- @local
	-- @table contextualMixins
	local contextualMixins = {
		SetContext = function(self, ctx)
			if type(ctx) ~= "string" then
				return
			end
			self:SetPrivateField("ctx", ctx)
		end,
		GetContext = function(self)
			return self:GetPrivateField("ctx")
		end,
	}

	return Object, stripDotExtension, enumerateAncestors, contextualMixins
end
local Object, stripDotExtension, enumerateAncestors, contextualMixins = initObject()
--- A type(class) checking library to extend `MiddleClass`'s functionality.
local function initTypeUtil()
	local TypeUtil = {}

	--- All the `Class` names in Log4g.
	-- @local
	-- @table Classes
	local Classes = {
		["Object"] = {
			["LifeCycle"] = true,
			["LoggerConfig.RootLogger"] = true,
			["LoggerConfig"] = true,
			["LogEvent"] = true,
			["LoggerContext"] = true,
			["Configuration"] = true,
			["Level"] = true,
			["Layout"] = true,
			["Logger"] = true,
			["Appender"] = true,
			["DefaultConfiguration"] = true,
			["PatternLayout"] = true,
			["ConsoleAppender"] = true,
		},
		["Configuration"] = {
			["DefaultConfiguration"] = true,
		},
		["LoggerConfig"] = {
			["LoggerConfig.RootLogger"] = true,
		},
		["Appender"] = {
			["ConsoleAppender"] = true,
		},
		["Layout"] = {
			["PatternLayout"] = true,
		},
		["LoggerContext"] = {},
		["Level"] = {},
		["Logger"] = {},
		["LogEvent"] = {},
		["LoggerConfig.RootLogger"] = {},
	}

	local function mkfunc_classcheck(cls, subClasses)
		return function(o)
			if not o or type(o) ~= "table" then
				return false
			end
			local classTable = o.class
			if not classTable then
				return false
			end
			local className = classTable.name

			if subClasses then
				for name in pairs(subClasses) do
					if name == className then
						return true
					end
				end
			end

			if className == cls then
				return true
			end

			return false
		end
	end

	for k, v in pairs(Classes) do
		TypeUtil["Is" .. k] = mkfunc_classcheck(k, v)
	end
	return TypeUtil
end

local TypeUtil = initTypeUtil()

--- Handles properties defined in the configuration.
-- Since every LoggerContext has a Configuration, the grouping of private properties is based on LoggerContext names.
local function initPropertiesPlugin()
	--- Holds all the properties that Configurations use.
	-- It contains 'Shared' and 'Private' two sub tables.
	-- @local
	-- @table Properties
	local Properties = Properties or {
		Shared = {},
		Private = {},
	}

	--- Register a property.
	-- @function registerProperty
	-- @param name Name of the property
	-- @param defaultValue Default value of the property
	-- @param shared If this property will be shared with every LoggerContexts
	-- @param context LoggerContext object
	local function registerProperty(name, defaultValue, shared, context)
		if type(name) ~= "string" or not defaultValue then
			return
		end

		if shared then
			Properties.Shared[name] = defaultValue
		elseif TypeUtil.IsLoggerContext(context) then
			local function ifSubTblNotExistThenCreate(tbl, key)
				if not tbl[key] then
					tbl[key] = {}
				end
			end

			local contextName = context:GetName()
			ifSubTblNotExistThenCreate(Properties.Private, contextName)
			Properties.Private[contextName][name] = defaultValue
		end
	end

	--- Gets a property.
	-- @function getProperty
	-- @param name Property name
	-- @param shared If the property is shared
	-- @param context LoggerContext object
	-- @return anytype value
	local function getProperty(name, shared, context)
		if type(name) ~= "string" then
			return
		end

		if shared then
			return Properties.Shared[name]
		elseif TypeUtil.IsLoggerContext(context) then
			local contextProperties = Properties.Private[context:GetName()]
			if not contextProperties then
				return
			end

			return contextProperties[name]
		end
	end
	--[[

--- Removes a property.
-- @function removeProperty
-- @param name Property name
-- @param shared If the property is shared
-- @param context LoggerContext object
local function removeProperty(name, shared, context)
    if type(name) ~= "string" then return end

    if shared then
        Properties.Shared[name] = nil
    elseif IsLoggerContext(context) then
        local contextName = context:GetName()
        local contextProperties = Properties.Private[contextName]
        if not contextProperties then return end
        contextProperties[name] = nil

        if not next(contextProperties) then
            Properties.Private[contextName] = nil
        end
    end
end

--- Get all properties.
-- @return table properties
local function getAll()
    return Properties
end
--]]

	return registerProperty, getProperty
end

local registerProperty, getProperty = initPropertiesPlugin()
