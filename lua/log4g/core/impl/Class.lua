--[[
Class.lua
Based on https://github.com/rxi/classic.

Copyright (c) 2014 rxi
Copyright (c) 2022 Christopher Stephen Rafuse, ImpishDeathTech
Copyright (c) 2023 GrayWolf64

This module is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See LICENSE for details.
]]
--
local Object = {}
Object.__index = Object
Object.__name = "class"

function Object:New()
end

function Object:Delete()
end

function Object:Extend(type_str)
    local cls = {}

    for k, v in pairs(self) do
        local num, _, _ = string.find(k, "__")

        if num ~= nil then
            cls[k] = v
        end
    end

    cls.__index = cls
    cls.__name = type_str or "object"
    cls.super = self
    setmetatable(cls, self)

    return cls
end

function Object:Fields(...)
    for _, cls in pairs({...}) do
        for k, v in pairs(cls) do
            if type(v) ~= "function" then
                self[k] = v
            end
        end
    end
end

function Object:Implement(...)
    for _, cls in pairs({...}) do
        for k, v in pairs(cls) do
            if self[k] == nil and type(v) == "function" then
                self[k] = v
            end
        end
    end
end

function Object:Override(...)
    for _, cls in pairs({...}) do
        for k, v in pairs(cls) do
            if (self[k] ~= nil) and (type[k] == "function") and (type(v) == "function") then
                self[k] = v
            end
        end
    end
end

function Object:Is(T)
    local mt = getmetatable(self)

    while mt do
        if mt == T then return true end
        mt = getmetatable(mt)
    end

    return false
end

function Object:Equals(cls)
    local retVal = true

    for k, v in pairs(cls) do
        if (self[k] == nil) or (self[k] ~= v) then
            retVal = false
            break
        end
    end

    return retVal
end

function Object:__call(...)
    local obj = setmetatable({}, self)
    obj:New(...)

    return obj
end

function Object:__gc()
    self:Delete()
end

function Object:__len()
    local c = 0

    for k, v in pairs(self) do
        c = c + 1
    end

    return c
end

return Object