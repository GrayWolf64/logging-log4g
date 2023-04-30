--- Handles properties defined in the configuration.
-- @script PropertiesPlugin
-- @license Apache License 2.0
-- @copyright GrayWolf64
local IsLoggerContext = Log4g.GetPkgClsFuncs("log4g-core", "TypeUtil").IsLoggerContext

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
    else
        if not context or not IsLoggerContext(context) then
            return
        else
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
    else
        if not context or not IsLoggerContext(context) then
            return
        else
            local contextProperties = Properties.Private[context:GetName()]
            if not contextProperties then return end

            return contextProperties[name]
        end
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
    else
        if not context or not IsLoggerContext(context) then
            return
        else
            local contextName = context:GetName()
            local contextProperties = Properties.Private[contextName]
            if not contextProperties then return end
            contextProperties[name] = nil

            if not next(contextProperties) then
                Properties.Private[contextName] = nil
            end
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