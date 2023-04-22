--- A simple OOP library for Lua which has inheritance, metamethods, class variables and weak mixin support.
-- @module MiddleClass
-- @license MIT License
-- @copyright Enrique García Cota
local MiddleClass = {}
local isstring, istable, isfunction = isstring, istable, isfunction

local function _createIndexWrapper(aClass, f)
    if f == nil then
        return aClass.__instanceDict
    elseif isfunction(f) then
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
                if result == nil then return super.static[k] end

                return result
            end,
        })
    else
        setmetatable(aClass.static, {
            __index = function(_, k) return rawget(dict, k) end,
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
    if not istable(mixin) then return end

    for name, method in pairs(mixin) do
        if name ~= "included" and name ~= "static" then
            aClass[name] = method
        end
    end

    for name, method in pairs(mixin.static or {}) do
        aClass.static[name] = method
    end

    if isfunction(mixin.included) then
        mixin:included(aClass)
    end

    return aClass
end

local DefaultMixin = {
    __tostring = function(self) return "instance of " .. tostring(self.class) end,
    Initialize = function(self, ...) end,
    isInstanceOf = function(self, aClass) return type(aClass) == "table" and type(self) == "table" and (self.class == aClass or type(self.class) == "table" and type(self.class.isSubclassOf) == "function" and self.class:isSubclassOf(aClass)) end,
    static = {
        allocate = function(self)
            if not istable(self) then return end

            return setmetatable({
                class = self,
            }, self.__instanceDict)
        end,
        New = function(self, ...)
            if not istable(self) then return end
            local instance = self:allocate()
            instance:Initialize(...)

            return instance
        end,
        subclass = function(self, name)
            if not istable(self) or not isstring(name) then return end
            local subclass = _createClass(name, self)

            for methodName, f in pairs(self.__instanceDict) do
                if not (methodName == "__index" and istable(f)) then
                    _propagateInstanceMethod(subclass, methodName, f)
                end
            end

            subclass.Initialize = function(instance, ...) return self.Initialize(instance, ...) end
            self.subclasses[subclass] = true
            self:subclassed(subclass)

            return subclass
        end,
        subclassed = function(self, other) end,
        isSubclassOf = function(self, other) return type(other) == "table" and type(self.super) == "table" and (self.super == other or self.super:isSubclassOf(other)) end,
        include = function(self, ...)
            if not istable(self) then return end

            for _, mixin in ipairs({...}) do
                _includeMixin(self, mixin)
            end

            return self
        end,
    },
}

function MiddleClass.class(name, super)
    if not isstring(name) then return end

    return super and super:subclass(name) or _includeMixin(_createClass(name), DefaultMixin)
end

setmetatable(MiddleClass, {
    __call = function(_, ...) return MiddleClass.class(...) end,
})

return MiddleClass