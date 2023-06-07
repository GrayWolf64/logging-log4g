--- Handles properties defined in the configuration.
-- Since every LoggerContext has a Configuration, the grouping of private properties is based on LoggerContext names.
-- @script PropertiesPlugin
-- @license Apache License 2.0
-- @copyright GrayWolf64
local checkClass = include("log4g/core/util/TypeUtil.lua").checkClass

--- Holds all the properties that Configurations use.
-- It contains 'Shared' and 'Private' two sub tables.
-- @local
-- @table Properties
local Properties = Properties or {
    Shared = {},
    Private = {}
}

--- Register a property.
-- @param name Name of the property
-- @param defaultValue Default value of the property
-- @param shared If this property will be shared with every LoggerContexts
-- @param context LoggerContext object
local function registerProperty(name, defaultValue, shared, context)
    if type(name) ~= "string" or not defaultValue then return end

    if shared then
        Properties.Shared[name] = defaultValue
    elseif checkClass(context, "LoggerContext") then
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
-- @param name Property name
-- @param shared If the property is shared
-- @param context LoggerContext object
-- @return anytype value
local function getProperty(name, shared, context)
    if type(name) ~= "string" then return end

    if shared then
        return Properties.Shared[name]
    elseif checkClass(context, "LoggerContext") then
        local contextProperties = Properties.Private[context:GetName()]
        if not contextProperties then return end

        return contextProperties[name]
    end
end

--- Removes a property.
-- @param name Property name
-- @param shared If the property is shared
-- @param context LoggerContext object
local function removeProperty(name, shared, context)
    if type(name) ~= "string" then return end

    if shared then
        Properties.Shared[name] = nil
    elseif checkClass(context, "LoggerContext") then
        local contextName = context:GetName()
        local contextProperties = Properties.Private[contextName]
        if not contextProperties then return end
        contextProperties[name] = nil

        if not next(contextProperties) then
            Properties.Private[contextName] = nil
        end
    end
end

local function getAll()
    return Properties
end

Log4g.RegisterPackageClass("log4g-core", "PropertiesPlugin", {
    registerProperty = registerProperty,
    getProperty = getProperty,
    removeProperty = removeProperty,
    getAll = getAll
})