--- Handles properties defined in the configuration.
-- @script PropertiesPlugin
-- @license Apache License 2.0
-- @copyright GrayWolf64
local IsConfiguration = Log4g.GetPkgClsFuncs("log4g-core", "TypeUtil").IsConfiguration
local pairs = pairs

local Properties = Properties or {
    Shared = {},
    Private = {}
}

--- Register a property.
-- @param name Name of the property
-- @param defaultValue Default value of the property
-- @param shared If this property will be shared with every Configurations
-- @param config Configuration object
local function registerProperty(name, defaultValue, shared, config)
    if type(name) ~= "string" or not defaultValue then return end

    if shared then
        Properties.Shared[name] = defaultValue
    else
        if not config or not IsConfiguration(config) then
            return
        else
            local function ifSubTblNotExistThenCreate(tbl, key)
                if not tbl[key] then
                    tbl[key] = {}
                end
            end

            local configName = config:GetName()
            ifSubTblNotExistThenCreate(Properties.Private, configName)
            Properties.Private[configName][name] = defaultValue
        end
    end
end

--- Gets a property.
-- @param name Property name
-- @param shared If the property is shared
-- @param config Configuration object
-- @return anytype value
local function getProperty(name, shared, config)
    if type(name) ~= "string" then return end

    if shared then
        return Properties.Shared[name]
    else
        if not config or not IsConfiguration(config) then
            for _, properties in pairs(Properties.Private) do
                for propertyName, property in pairs(properties) do
                    if propertyName == name then return property end
                end
            end
        else
            local configProperties = Properties.Private[config:GetName()]
            if not configProperties then return end

            return configProperties[name]
        end
    end
end

--- Removes a property.
-- @param name Property name
-- @param shared If the property is shared
-- @param config Configuration object
local function removeProperty(name, shared, config)
    if type(name) ~= "string" then return end

    if shared then
        Properties[name] = nil
    else
        local function ifSubTblEmptyThenRemove(tbl, key)
            if not next(tbl[key]) then
                tbl[key] = nil
            end
        end

        if not config or not IsConfiguration(config) then
            for configName, properties in pairs(Properties.Private) do
                for propertyName, property in pairs(properties) do
                    if propertyName == name then
                        Properties.Private[configName][name] = nil
                        ifSubTblEmptyThenRemove(Properties.Private, configName)
                    end
                end
            end
        else
            local configProperties = Properties.Private[config:GetName()]
            if not configProperties then return end
            configProperties[name] = nil
            ifSubTblEmptyThenRemove(Properties.Private, configName)
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