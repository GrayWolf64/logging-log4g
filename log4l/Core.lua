--- Implementation of Log4l.
-- @module Core
-- @license Apache License 2.0, MIT License
-- @copyright GrayWolf64
local type = type
local pairs, ipairs = pairs, ipairs
local next = next
local tonumber = tonumber
local osClock = os.clock
local tableConcat = table.concat

--- A simple OOP library for Lua which has inheritance, metamethods, class variables and weak mixin support.
local function initMiddleClass()
    local setmetatable = setmetatable
    local rawget = rawget
    local MiddleClass = {}

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
                __mode = "k"
            })
        }

        if super then
            setmetatable(aClass.static, {
                __index = function(_, k)
                    local result = rawget(dict, k)
                    if result == nil then
                        return super.static[k]
                    end

                    return result
                end
            })
        else
            setmetatable(aClass.static, {
                __index = function(_, k)
                    return rawget(dict, k)
                end
            })
        end

        setmetatable(aClass, {
            __index = aClass.static,
            __tostring = _tostring,
            __call = _call,
            __newindex = _declareInstanceMethod
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
        Initialize = function(self, ...)
        end,
        isInstanceOf = function(self, aClass)
            return type(aClass) == "table" and type(self) == "table" and
                       (self.class == aClass or type(self.class) == "table" and type(self.class.isSubclassOf) ==
                           "function" and self.class:isSubclassOf(aClass))
        end,
        static = {
            allocate = function(self)
                if type(self) ~= "table" then
                    return
                end

                return setmetatable({
                    class = self
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
            subclassed = function(self, other)
            end,
            isSubclassOf = function(self, other)
                return type(other) == "table" and type(self.super) == "table" and
                           (self.super == other or self.super:isSubclassOf(other))
            end,
            include = function(self, ...)
                if type(self) ~= "table" then
                    return
                end

                for _, mixin in ipairs({...}) do
                    _includeMixin(self, mixin)
                end

                return self
            end
        }
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
        end
    })

    return MiddleClass
end

local MiddleClass = initMiddleClass()

local function initObject()
    --- Class Object is the root of the class hierarchy.
    -- @type Object
    local Object = MiddleClass("Object")

    --- A table for storing private properties of an object.
    -- @local
    -- @table _privateAttr
    local _privateAttr = _privateAttr or setmetatable({}, {
        __mode = "k"
    })

    --- When an Object is initialized, a private field(sub table) in the `PRIVATE` table will be dedicated to it based on `self` key.
    function Object:Initialize()
        _privateAttr[self] = {}
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
        _privateAttr[self].name = name
    end

    --- Gets the name of the Object.
    -- @return string name
    function Object:GetName()
        return _privateAttr[self].name
    end

    --- Sets a private field for the Object.
    -- @param key Of any type except nil
    -- @param value Of any type except nil
    function Object:SetPrivateField(key, value)
        if not key or not value then
            return
        end
        _privateAttr[self][key] = value
    end

    --- Gets a private field of the Object.
    -- @param key Of any type except nil
    -- @return anytype private value
    function Object:GetPrivateField(key)
        if not key then
            return
        end

        return _privateAttr[self][key]
    end

    --- Destroys its private table.
    function Object:DestroyPrivateTable()
        _privateAttr[self] = nil
    end

    --- Removes the dot extension of a string.
    -- Internally uses an optimized version of [string.Explode](https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/extensions/string.lua#L87-L104).
    -- @param str String
    -- @param doconcat Whether `table.concat` the result
    -- @return string result
    local function stripDotExtension(str, doconcat)
        if type(str) ~= "string" then
            return
        end
        str = str:sub(1, #str - str:reverse():find("%."))
        local result, currentPos = {}, 1

        for i = 1, #str do
            local startPos, endPos = str:find(".", currentPos, true)
            if not startPos then
                break
            end
            result[i], currentPos = str:sub(currentPos, startPos - 1), endPos + 1
        end

        result[#result + 1] = str:sub(currentPos)

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
        end
    }

    return Object, stripDotExtension, enumerateAncestors, contextualMixins
end

local Object, stripDotExtension, enumerateAncestors, contextualMixins = initObject()

--- A type(class) checking library to extend `MiddleClass`'s functionality.
local function initTypeUtil()
    local TypeUtil = {}

    --- All the `Class` names in Log4l.
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
            ["ConsoleAppender"] = true
        },
        ["Configuration"] = {
            ["DefaultConfiguration"] = true
        },
        ["LoggerConfig"] = {
            ["LoggerConfig.RootLogger"] = true
        },
        ["Appender"] = {
            ["ConsoleAppender"] = true
        },
        ["Layout"] = {
            ["PatternLayout"] = true
        },
        ["LoggerContext"] = {},
        ["Level"] = {},
        ["Logger"] = {},
        ["LogEvent"] = {},
        ["LoggerConfig.RootLogger"] = {}
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
local IsLoggerContext = TypeUtil.IsLoggerContext
local IsAppender = TypeUtil.IsAppender
local IsConfiguration = TypeUtil.IsConfiguration
local IsLogEvent = TypeUtil.IsLogEvent
local IsLevel = TypeUtil.IsLevel

--- Handles properties defined in the configuration.
-- Since every LoggerContext has a Configuration, the grouping of private properties is based on LoggerContext names.
local function initPropertiesPlugin()
    --- Holds all the properties that Configurations use.
    -- It contains '_sh' and '_pvt' two sub tables, standing for 'Shared' and 'Private'.
    -- @local
    -- @table _properties
    local _properties = _properties or {
        _sh = {},
        _pvt = {}
    }

    --- Register a property.
    -- @param name Name of the property
    -- @param defaultValue Default value of the property
    -- @param shared If this property will be shared with every LoggerContexts
    -- @param context LoggerContext object
    local function registerProperty(name, defaultValue, shared, context)
        if type(name) ~= "string" or not defaultValue then
            return
        end

        if shared then
            _properties._sh[name] = defaultValue
        elseif TypeUtil.IsLoggerContext(context) then
            local function ifSubTblNotExistThenCreate(tbl, key)
                if not tbl[key] then
                    tbl[key] = {}
                end
            end

            local contextName = context:GetName()
            ifSubTblNotExistThenCreate(_properties._pvt, contextName)
            _properties._pvt[contextName][name] = defaultValue
        end
    end

    --- Gets a property.
    -- @param name Property name
    -- @param shared If the property is shared
    -- @param context LoggerContext object
    -- @return anytype value
    local function getProperty(name, shared, context)
        if type(name) ~= "string" then
            return
        end

        if shared then
            return _properties._sh[name]
        elseif TypeUtil.IsLoggerContext(context) then
            local contextProperties = _properties._pvt[context:GetName()]
            if not contextProperties then
                return
            end

            return contextProperties[name]
        end
    end

    --- Removes a property.
    -- @param name Property name
    -- @param shared If the property is shared
    -- @param context LoggerContext object
    local function removeProperty(name, shared, context)
        if type(name) ~= "string" then
            return
        end

        if shared then
            _properties._sh[name] = nil
        elseif IsLoggerContext(context) then
            local contextName = context:GetName()
            local contextProperties = _properties._pvt[contextName]
            if not contextProperties then
                return
            end
            contextProperties[name] = nil

            if not next(contextProperties) then
                _properties._pvt[contextName] = nil
            end
        end
    end

    --- Gets all the properties registered in `PropertiesPlugin`.
    local function getAllProperties()
        return _properties
    end

    return registerProperty, getProperty, removeProperty, getAllProperties
end

local registerProperty, getProperty, removeProperty, getAllProperties = initPropertiesPlugin()

local function initLifeCycle()
    --- In Log4l, the main interface for handling the life cycle context of an object is this one.
    -- An object first starts in the LifeCycle.State.INITIALIZED state by default to indicate the class has been loaded.
    -- From here, calling the `Start()` method will change this state to LifeCycle.State.STARTING.
    -- After successfully being started, this state is changed to LifeCycle.State.STARTED.
    -- When the `Stop()` is called, this goes into the LifeCycle.State.STOPPING state.
    -- After successfully being stopped, this goes into the LifeCycle.State.STOPPED state.
    -- In most circumstances, implementation classes should store their LifeCycle.State in a volatile field dependent on synchronization and concurrency requirements.
    -- @type LifeCycle
    local LifeCycle = Object:subclass("LifeCycle")

    --- LifeCycle states.
    -- @local
    -- @table State
    -- @field INITIALIZING Object is in its initial state and not yet initialized.
    -- @field INITIALIZED Initialized but not yet started.
    -- @field STARTING In the process of starting.
    -- @field STARTED Has started.
    -- @field STOPPING Stopping is in progress.
    -- @field STOPPED Has stopped.
    local State = {
        INITIALIZING = function()
            return 100
        end,
        INITIALIZED = function()
            return 200
        end,
        STARTING = function()
            return 300
        end,
        STARTED = function()
            return 400
        end,
        STOPPING = function()
            return 500
        end,
        STOPPED = function()
            return 600
        end
    }

    function LifeCycle:Initialize()
        Object.Initialize(self)
        self:SetState(State.INITIALIZED)
    end

    --- Sets the LifeCycle state.
    -- @param state A function in the `State` table which returns a string representing the state
    function LifeCycle:SetState(state)
        if type(state) ~= "function" then
            return
        end
        self:SetPrivateField("state", state)
    end

    --- Sets the `START` state.
    function LifeCycle:Start()
        self:SetState(State.STARTED)
    end

    --- Sets the `STOPPING` state.
    function LifeCycle:SetStopping()
        self:SetState(State.STOPPING)
    end

    --- Sets the `STOPPED` state.
    function LifeCycle:SetStopped()
        self:SetState(State.STOPPED)
    end

    --- Gets the LifeCycle state.
    -- @return function state
    function LifeCycle:GetState()
        return self:GetPrivateField("state")
    end

    return LifeCycle
end

local LifeCycle = initLifeCycle()

--- A `Color` abstraction layer, and we still use this constructor when GMod's `Color()` is available so it won't be recognized as a color by `IsColor()`.
-- GMod uses `Color` in a similar way, see [garrysmod/lua/includes/util/color.lua](https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/util/color.lua).
-- @param r red
-- @param g green
-- @param b blue
-- @param a alpha, default is 255
-- @return table {r = int, g = int, b = int, a = int}
local function mkColor(r, g, b, a)
    a = a or 255

    return {
        r = r,
        g = g,
        b = b,
        a = a
    }
end

local function initAppender()
    --- Lays out a LogEvent in different formats.
    -- @type Layout
    local Layout = Object:subclass("Layout")

    function Layout:Initialize(name)
        Object.Initialize(self)
        self:SetName(name)
    end

    function Layout:__tostring()
        return "Layout: [name:" .. self:GetName() .. "]"
    end

    --- An Appender can contain a Layout if applicable.
    -- @type Appender
    local Appender = LifeCycle:subclass("Appender")

    function Appender:Initialize(name, layout)
        LifeCycle.Initialize(self)
        self:SetPrivateField("layout", layout)
        self:SetName(name)
    end

    function Appender:__tostring()
        return "Appender: [name:" .. self:GetName() .. "]"
    end

    --- Returns the Layout used by this Appender if applicable.
    -- @return object Layout
    function Appender:GetLayout()
        return self:GetPrivateField("layout")
    end

    --- Prototype function for other types of Appenders to override.
    -- @return bool true
    function Appender:Append()
        return true
    end

    --- The goal of this class is to format a LogEvent and return the results. The format of the result depends on the conversion pattern.
    -- @type PatternLayout
    local PatternLayout = Layout:subclass("PatternLayout")
    local tableInsert, tableRemove = table.insert, table.remove
    local propertyConversionPattern = "patternlayoutConversionPattern"
    local propertyMessageColor = "patternlayoutMessageColor"
    local propertyUptimeColor = "patternlayoutUptimeColor"
    local propertyFileColor = "patternlayoutFileColor"
    registerProperty(propertyConversionPattern, "[%uptime] [%level] @ %file: %msg%endl", true)
    registerProperty(propertyMessageColor, "135 206 250 255", true)
    registerProperty(propertyUptimeColor, "135 206 250 255", true)
    registerProperty(propertyFileColor, "60 179 113 255", true)

    function PatternLayout:Initialize(name)
        Layout.Initialize(self, name)
    end

    --- Format the LogEvent using patterns.
    -- @param event LogEvent
    -- @param colored If use `Color`s.
    -- @return vararg formatted event in sub strings
    local function DoFormat(event, colored)
        local conversionPattern = getProperty(propertyConversionPattern, true)

        --- Get all the positions of a char in a string.
        -- @param str String to search in
        -- @param char A Single character to search for
        -- @return table positions or true if not found
        local function charPos(str, char)
            if type(str) ~= "string" or type(char) ~= "string" or not #char == 1 then
                return
            end
            local charPoses = {}
            char = char:byte()

            for pos, asciiCode in ipairs({str:byte(1, #str)}) do
                if asciiCode == char then
                    tableInsert(charPoses, pos)
                end
            end

            return not #charPoses or charPoses
        end

        local charPoses = charPos(conversionPattern, "%")
        if charPoses == true then
            return conversionPattern
        end
        local subStrings, pointerPos = {}, 1

        for index, pos in ipairs(charPoses) do
            local previousPos, nextPos = charPoses[index - 1], charPoses[index + 1]

            if previousPos then
                pointerPos = previousPos
            end

            if pos - 1 ~= 0 then
                subStrings[index] = conversionPattern:sub(pointerPos, pos - 1)
            end

            if not nextPos then
                subStrings[index + 1] = conversionPattern:sub(pos, #conversionPattern)
            end
        end

        local defaultColor = mkColor(0, 201, 255)

        local function getPropertyColor(cvar)
            if not colored then
                return
            end
            local r, g, b, a = getProperty(cvar, true):match "(%d+) (%d+) (%d+) (%d+)"

            return mkColor(tonumber(r) or 255, tonumber(g) or 255, tonumber(b) or 255, tonumber(a) or 255)
        end

        local eventLevel = event:GetLevel()

        local tokenMap = {
            ["%msg"] = {
                color = getPropertyColor(propertyMessageColor),
                content = event:GetMsg()
            },
            ["%endl"] = {
                content = "\n"
            },
            ["%uptime"] = {
                color = getPropertyColor(propertyUptimeColor),
                content = event:GetTime()
            },
            ["%file"] = {
                color = getPropertyColor(propertyFileColor),
                content = event:GetSource():GetFileFromFilename()
            },
            ["%level"] = {
                color = eventLevel:GetColor(),
                content = eventLevel:GetName()
            }
        }

        for tokenName in pairs(tokenMap) do
            for index, subString in ipairs(subStrings) do
                if subString:find(tokenName, 1, true) then
                    local previousValue = subStrings[index]
                    tableRemove(subStrings, index)
                    tableInsert(subStrings, index, tokenName)
                    tableInsert(subStrings, index + 1, previousValue:sub(#tokenName + 1, #previousValue))
                end
            end
        end

        --- Make a function that can replace a table's matching values with replacement content(string),
        -- and insert a Color before each replaced value. Based on `colored` bool, it will decide if `Color`s will be inserted.
        -- @param tokenName String to search for and to be replaced
        -- @param color Color object to insert before each replaced value
        -- @return function output func
        local function mkfunc_precolor(tokenName, color)
            return function(subStringTable, content)
                local function insertColor(index)
                    if colored then
                        if color then
                            tableInsert(subStringTable, index, color)
                        else
                            tableInsert(subStringTable, index, defaultColor)
                        end

                        tableInsert(subStringTable, index + 2, defaultColor)
                    end
                end

                for index, subString in ipairs(subStringTable) do
                    if subString == tokenName then
                        subStringTable[index] = content
                        insertColor(index)
                    end
                end
            end
        end

        for tokenName, mappedReplacements in pairs(tokenMap) do
            mkfunc_precolor(tokenName, mappedReplacements.color)(subStrings, mappedReplacements.content)
        end

        return unpack(subStrings)
    end

    --- Format a LogEvent.
    -- @param event LogEvent
    -- @param colored If use `Color`s.
    -- @return vararg result
    function PatternLayout:Format(event, colored)
        if not IsLogEvent(event) then
            return
        end

        return DoFormat(event, colored)
    end

    --- Create a default PatternLayout.
    local function createDefaultPatternLayout(name)
        return PatternLayout(name)
    end

    --- Appends log events to console using a layout specified by the user.
    -- @type ConsoleAppender
    local ConsoleAppender = Appender:subclass("ConsoleAppender")
    local IsLayout = TypeUtil.IsLayout

    function ConsoleAppender:Initialize(name, layout)
        Appender.Initialize(self, name, layout)
    end

    --- Append a LogEvent to Console.
    -- @param event LogEvent
    -- @param outputFunc A function which takes in vararg and output them to any kinds of console
    -- @param useColors Tells the ConsoleAppender's Layout whether or not use `Color` tables returned by `mkColor`. Notice that `outputFunc` should support colored outputs.
    function ConsoleAppender:Append(event, outputFunc, useColors)
        if not IsLogEvent(event) or type(outputFunc) ~= "function" then
            return
        end
        local layout = self:GetLayout()
        if not IsLayout(layout) then
            return
        end
        outputFunc(layout:Format(event, useColors))
    end

    --- Create a default ConsoleAppender.
    -- @param name String name for the ConsoleAppender
    -- @param layout Layout object
    -- @return object ConsoleAppender
    local function createConsoleAppender(name, layout)
        return ConsoleAppender(name, layout)
    end

    return createConsoleAppender, createDefaultPatternLayout
end

local createConsoleAppender, createDefaultPatternLayout = initAppender()
--- A dictionary for storing LoggerContext objects.
-- Only one ContextDictionary exists in the logging system.
-- @local
-- @table _contextDict
local _contextDict = _contextDict or {}

local function initLoggerContext()
    --- Interface that must be implemented to create a Configuration.
    -- @type Configuration
    local Configuration = LifeCycle:subclass("Configuration")
    Configuration:include(contextualMixins)

    function Configuration:Initialize(name)
        LifeCycle.Initialize(self)
        self:SetPrivateField("ap", {})
        self:SetPrivateField("lc", {})
        self:SetPrivateField("start", osClock())
        self:SetName(name)
    end

    function Configuration:__tostring()
        return "Configuration: [name:" .. self:GetName() .. "]"
    end

    --- Adds a Appender to the Configuration.
    -- @param ap The Appender to add
    -- @return bool ifsuccessfullyadded
    function Configuration:AddAppender(ap)
        if not IsAppender(ap) then
            return
        end
        if self:GetPrivateField("ap")[ap:GetName()] then
            return false
        end
        self:GetPrivateField("ap")[ap:GetName()] = ap

        return true
    end

    function Configuration:RemoveAppender(name)
        self:GetPrivateField("ap")[name] = nil
    end

    --- Gets all the Appenders in the Configuration.
    -- Keys are the names of Appenders and values are the Appenders themselves.
    -- @return table appenders
    function Configuration:GetAppenders()
        return self:GetPrivateField("ap")
    end

    function Configuration:AddLogger(name, lc)
        self:GetPrivateField("lc")[name] = lc
    end

    --- Locates the appropriate LoggerConfig name for a Logger name.
    -- @param name The Logger name
    -- @return object loggerconfig
    function Configuration:GetLoggerConfig(name)
        return self:GetPrivateField("lc")[name]
    end

    function Configuration:GetLoggerConfigs()
        return self:GetPrivateField("lc")
    end

    function Configuration:GetRootLogger()
        return self:GetPrivateField("lc")[getProperty("rootLoggerName", true)]
    end

    --- Gets how long since this Configuration initialized.
    -- @return int uptime
    function Configuration:GetUpTime()
        return osClock() - self:GetPrivateField("start")
    end

    --- Create a Configuration.
    -- @param name The name of the Configuration
    -- @return object configuration
    local function createConfiguration(name)
        if type(name) ~= "string" then
            return
        end

        return Configuration(name)
    end

    --- The default configuration writes all output to the Console using the default logging level.
    -- @type DefaultConfiguration
    local DefaultConfiguration = Configuration:subclass("DefaultConfiguration")
    registerProperty("configurationDefaultName", "default", true)
    registerProperty("configurationDefaultLevel", "DEBUG", true)

    --- Initialize the DefaultConfiguration.
    -- @param name String name.
    function DefaultConfiguration:Initialize(name)
        Configuration.Initialize(self, name)
        self:SetPrivateField("defaultlevel", getProperty("configurationDefaultLevel", true))
    end

    --- Gets a DefaultConfiguration.
    -- @section end
    local function getDefaultConfiguration()
        local name = getProperty("configurationDefaultName", true)
        local configuration = DefaultConfiguration(name)
        configuration:AddAppender(
            createConsoleAppender(name .. "Appender", createDefaultPatternLayout(name .. "Layout")))

        return configuration
    end

    --- The LoggerContext is the anchor for the logging system. It maintains a list of all the loggers requested by applications and a reference to the Configuration.
    -- @type LoggerContext
    local LoggerContext = LifeCycle:subclass("LoggerContext")

    function LoggerContext:Initialize(name)
        LifeCycle.Initialize(self)
        self:SetPrivateField("logger", {})
        self:SetName(name)
    end

    --- Sets the Configuration source for the LoggerContext.
    -- @param src String source
    function LoggerContext:SetConfigurationSource(src)
        self:SetPrivateField("source", src)
    end

    --- Gets where this LoggerContext is declared.
    -- @return table source
    function LoggerContext:GetConfigurationSource()
        return self:GetPrivateField("source")
    end

    --- Gets a Logger from the Context.
    -- @param name The name of the Logger
    function LoggerContext:GetLogger(name)
        return self:GetPrivateField("logger")[name]
    end

    --- Gets a table of the current loggers.
    -- @return table loggers
    function LoggerContext:GetLoggers()
        return self:GetPrivateField("logger")
    end

    function LoggerContext:AddLogger(name, logger)
        self:GetPrivateField("logger")[name] = logger
    end

    --- Returns the current Configuration of the LoggerContext.
    -- @return object configuration
    function LoggerContext:GetConfiguration()
        return self:GetPrivateField("config")
    end

    --- Sets the Configuration to be used.
    -- @param config Configuration
    function LoggerContext:SetConfiguration(config)
        if not IsConfiguration(config) then
            return
        end
        if self:GetConfiguration() == config then
            return
        end
        config:SetContext(self:GetName())
        self:SetPrivateField("config", config)
    end

    function LoggerContext:__tostring()
        return "LoggerContext: [name:" .. self:GetName() .. "]"
    end

    --- Terminate the LoggerContext.
    function LoggerContext:Terminate()
        local name = self:GetName()
        self:DestroyPrivateTable()
        _contextDict[name] = nil
    end

    --- Determines if the specified Logger exists.
    -- @param name The name of the Logger to check
    -- @return bool haslogger
    function LoggerContext:HasLogger(name)
        if self:GetLogger(name) then
            return true
        end

        return false
    end

    --- Register a LoggerContext.
    -- @param name The name of the LoggerContext
    -- @param withconfig Whether or not come with a DefaultConfiguration, leaving it nil will make it come with one
    -- @return object loggercontext
    local function registerContext(name, withconfig)
        if type(name) ~= "string" then
            return
        end
        local ctx = _contextDict[name]
        if IsLoggerContext(ctx) then
            return ctx
        end
        ctx = LoggerContext(name)

        if withconfig or withconfig == nil then
            ctx:SetConfiguration(getDefaultConfiguration())
        end

        _contextDict[name] = ctx

        return ctx
    end

    --- Get the number of Loggers across all the LoggerContexts.
    -- @return number count
    local function getLoggerCount()
        local num, count = 0, function(t)
            local i = 0

            for _ in pairs(t) do
                i = i + 1
            end

            return i
        end

        for _, v in pairs(_contextDict) do
            num = num + count(v:GetLoggers())
        end

        return num
    end

    return createConfiguration, getDefaultConfiguration, getLoggerCount, registerContext
end

local createConfiguration, getDefaultConfiguration, getLoggerCount, registerContext = initLoggerContext()

local function initLevel()
    --- Levels used for identifying the severity of an event.
    -- @type Level
    local Level = Object:subclass("Level")

    function Level:Initialize(name, int, color)
        Object.Initialize(self)
        self:SetPrivateField("int", int)
        self:SetPrivateField("color", color)
        self:SetName(name)
    end

    function Level:__tostring()
        return "Level: [name:" .. self:GetName() .. "]" .. "[int:" .. self:IntLevel() .. "]" .. "[color:" ..
                   self:GetColor():__tostring() .. "]"
    end

    function Level:__eq(lhs, rhs)
        if not IsLevel(lhs) or not IsLevel(rhs) then
            return false
        end

        return lhs:IntLevel() == rhs:IntLevel() and lhs:GetColor() == rhs:GetColor()
    end

    --- Get the Level's intlevel.
    -- @return int intlevel
    function Level:IntLevel()
        return self:GetPrivateField("int")
    end

    --- Get the Level's Color.
    -- @return object color
    function Level:GetColor()
        return self:GetPrivateField("color")
    end

    --- Compares the Level against the Levels passed as arguments and returns true if this level is in between the given levels.
    -- @param l1 The Level with a certain intlevel
    -- @param l2 The Level with another intlevel
    -- @return bool isinrange
    function Level:IsInRange(l1, l2)
        if not IsLevel(l1) or not IsLevel(l2) then
            return
        end
        if (self:IntLevel() >= l1:IntLevel() and self:IntLevel() <= l2:IntLevel()) or
            (self:IntLevel() <= l1:IntLevel() and self:IntLevel() >= l2:IntLevel()) then
            return true
        end

        return false
    end

    --- Custom Logging Levels created by users.
    -- @local
    -- @table CustomLevel
    local CustomLevel = CustomLevel or {}

    --- Standard Int Levels.
    -- @local
    -- @table StdIntLevel
    local StdIntLevel = {
        ALL = math.huge,
        TRACE = 600,
        DEBUG = 500,
        INFO = 400,
        WARN = 300,
        ERROR = 200,
        FATAL = 100,
        OFF = 0
    }

    --- Standard Level Colors.
    -- @local
    -- @table StdLevelColor
    local StdLevelColor = {
        ALL = mkColor(255, 255, 255),
        TRACE = mkColor(54, 54, 54),
        DEBUG = mkColor(0, 255, 255),
        INFO = mkColor(0, 255, 0),
        WARN = mkColor(255, 255, 0),
        ERROR = mkColor(255, 0, 0),
        FATAL = mkColor(255, 48, 48),
        OFF = mkColor(255, 255, 255)
    }

    --- Standard Logging Levels as a table.
    -- @local
    -- @table StdLevel
    -- @field ALL All events should be logged.
    -- @field TRACE A fine-grained debug message, typically capturing the flow through the game.
    -- @field DEBUG A general debugging event.
    -- @field INFO An event for informational purposes.
    -- @field WARN An event that might possible lead to an error.
    -- @field ERROR An error in game, possibly recoverable.
    -- @field FATAL A severe error that will prevent the game from continuing.
    -- @field OFF No events will be logged.
    local StdLevel = {}

    for k, v in pairs(StdIntLevel) do
        StdLevel[k] = Level(k, v, StdLevelColor[k])
    end

    --- Get the Level.
    -- Return the Level associated with the name or nil if the Level cannot be found.
    -- @param name The Level's name
    -- @return object level
    local function getLevel(name)
        if StdLevel[name] then
            return StdLevel[name]
        elseif CustomLevel[name] then
            return CustomLevel[name]
        end
    end

    --- Retrieves an existing CustomLevel or creates one if it didn't previously exist.
    -- If the CustomLevel matching the provided name already exists, it's intlevel will be overrode.
    -- @param name The Level's name
    -- @param int The Level's intlevel
    -- @return object level
    local function createLevel(name, int)
        if type(name) ~= "string" or type(int) ~= "number" or StdLevel[name] then
            return
        end
        if #name == 0 or int <= 0 then
            return
        end

        if not CustomLevel[name] then
            local level = Level(name, int)
            CustomLevel[name] = level

            return level
        else
            CustomLevel[name].int = int

            return CustomLevel[name]
        end
    end

    return getLevel, createLevel
end

local getLevel, createLevel = initLevel()

local function initLogger()
    local IsLoggerConfig = TypeUtil.IsLoggerConfig
    registerProperty("rootLoggerName", "root", true)
    --- Logger object that is created via configuration.
    -- @type LoggerConfig
    local LoggerConfig = LifeCycle:subclass("LoggerConfig")
    LoggerConfig:include(contextualMixins)

    function LoggerConfig:Initialize(name)
        LifeCycle.Initialize(self)
        self:SetPrivateField("apref", {})
        self:SetName(name)
    end

    function LoggerConfig:__tostring()
        return "LoggerConfig: [name:" .. self:GetName() .. "]"
    end

    --- Sets the log Level.
    -- @param level The Logging Level
    function LoggerConfig:SetLevel(level)
        if not IsLevel(level) then
            return
        end
        if self:GetPrivateField("level") == level then
            return
        end
        self:SetPrivateField("level", level)
    end

    function LoggerConfig:GetLevel()
        return self:GetPrivateField("level")
    end

    local function hasLoggerConfig(name, context)
        local getLoggerConfig = function(ctx, lcn)
            return ctx:GetConfiguration():GetLoggerConfig(lcn)
        end

        if not IsLoggerContext(context) then
            for _, v in pairs(_contextDict) do
                if getLoggerConfig(v, name) then
                    return true
                end
            end
        else
            if getLoggerConfig(context, name) then
                return true
            end
        end

        return false
    end

    local function GetLoggerConfig(name)
        for _, v in pairs(_contextDict) do
            local loggerConfig = v:GetConfiguration():GetLoggerConfig(name)
            if loggerConfig then
                return loggerConfig
            end
        end
    end

    --- Sets the parent of this LoggerConfig.
    -- @param T LoggerConfig object or LoggerConfig name
    function LoggerConfig:SetParent(T)
        if type(T) == "string" then
            if not hasLoggerConfig(T, _contextDict[self:GetContext()]) then
                return
            end
            self:SetPrivateField("parent", T)
        elseif IsLoggerConfig(T) and T:GetContext() == self:GetContext() then
            self:SetPrivateField("parent", T:GetName())
        end
    end

    --- Gets the parent of this LoggerConfig.
    -- @return string lcname
    function LoggerConfig:GetParent()
        return self:GetPrivateField("parent")
    end

    function LoggerConfig:GetAppenderRef()
        return self:GetPrivateField("apref")
    end

    --- Adds an Appender to the LoggerConfig.
    -- It adds the Appender name to the LoggerConfig's private `apref` table field,
    -- then adds the Appender object to the Configuration's(the only one which owns this LoggerConfig) private `appender` table field.
    -- @param ap Appender object
    -- @return bool ifadded
    function LoggerConfig:AddAppender(ap)
        if not IsAppender(ap) then
            return
        end
        self:GetAppenderRef()[ap:GetName()] = true

        return _contextDict[self:GetContext()]:GetConfiguration():AddAppender(ap, self:GetName())
    end

    --- Returns all Appenders configured by this LoggerConfig in a form of table (keys are Appenders, values are booleans).
    -- @return table appenders
    function LoggerConfig:GetAppenders()
        local appenders, config, apref = {}, _contextDict[self:GetContext()]:GetConfiguration(), self:GetAppenderRef()
        if not next(apref) then
            return
        end

        for appenderName in pairs(apref) do
            appenders[config:GetAppenders()[appenderName]] = true
        end

        return appenders
    end

    --- Removes all Appenders configured by this LoggerConfig.
    function LoggerConfig:ClearAppenders()
        local config, apref = _contextDict[self:GetContext()]:GetConfiguration(), self:GetAppenderRef()
        if not next(apref) then
            return
        end

        for appenderName in pairs(apref) do
            config:RemoveAppender(appenderName)
            self:GetAppenderRef()[appenderName] = nil
        end
    end

    --- The root LoggerConfig.
    -- @type LoggerConfig.RootLogger
    local RootLoggerConfig = LoggerConfig:subclass("LoggerConfig.RootLogger")

    function RootLoggerConfig:Initialize()
        LoggerConfig.Initialize(self, getProperty("rootLoggerName", true))
        self:SetLevel(getLevel("INFO"))
    end

    function RootLoggerConfig:__tostring()
        return "RootLoggerConfig: [name:" .. self:GetName() .. "]"
    end

    --- Overrides `LoggerConfig:SetParent()`.
    -- @return bool false
    function RootLoggerConfig:SetParent()
        return false
    end

    --- Overrides `LoggerConfig:GetParent()`.
    -- @return bool false
    function RootLoggerConfig:GetParent()
        return false
    end

    -- @section end
    --- Check if a LoggerConfig's ancestors exist and return its desired parent name.
    -- @param loggerConfig LoggerConfig object
    -- @return bool valid
    -- @return string parent name
    local function ValidateAncestors(loggerConfig)
        local ancestors, nodes = enumerateAncestors(loggerConfig:GetName())

        local function HasEveryLoggerConfig(tbl)
            local ctx = _contextDict[loggerConfig:GetContext()]

            for k in pairs(tbl) do
                if not hasLoggerConfig(k, ctx) then
                    return false
                end
            end

            return true
        end

        if HasEveryLoggerConfig(ancestors) then
            return true, tableConcat(nodes, ".")
        end

        return false
    end

    --- Factory method to create a LoggerConfig.
    -- @param name The name for the Logger
    -- @param config The Configuration
    -- @param level The Logging Level
    -- @return object loggerconfig
    local function createLoggerConfig(name, config, level)
        local root = getProperty("rootLoggerName", true)
        if not IsConfiguration(config) or name == root then
            return
        end
        local loggerConfig = LoggerConfig(name)
        loggerConfig:SetContext(config:GetContext())

        local setLevelAndParent = function(o, level1, level2, parent)
            if IsLevel(level1) then
                o:SetLevel(level1)
            else
                o:SetLevel(level2)
            end

            o:SetParent(parent)
        end

        if name:find("%.") then
            local valid, parent = ValidateAncestors(loggerConfig)
            if not valid then
                return
            end
            setLevelAndParent(loggerConfig, level, GetLoggerConfig(parent):GetLevel(), parent)
        else
            setLevelAndParent(loggerConfig, level, config:GetRootLogger():GetLevel(), root)
        end

        config:AddLogger(name, loggerConfig)

        return loggerConfig
    end

    --- Provides contextual information about a logged message.
    -- A LogEvent must be Serializable so that it may be transmitted over a network connection.
    -- @type LogEvent
    local LogEvent = Object:subclass("LogEvent")
    local debugGetInfo = debug.getinfo

    --- Initialize the LogEvent.
    -- @param ln Logger name
    -- @param level Level object
    -- @param time Precise time
    -- @param msg Log message
    -- @param src File source path
    function LogEvent:Initialize(ln, level, time, msg, src)
        Object.Initialize(self)
        self:SetPrivateField("ln", ln)
        self:SetPrivateField("lv", level)
        self:SetPrivateField("time", time)
        self:SetPrivateField("msg", msg)
        self:SetPrivateField("src", src)
    end

    --- Gets the Logger name.
    function LogEvent:GetLoggerName()
        return self:GetPrivateField("ln")
    end

    --- Gets the Level object.
    function LogEvent:GetLevel()
        return self:GetPrivateField("lv")
    end

    --- Gets the File source path.
    function LogEvent:GetSource()
        return self:GetPrivateField("src")
    end

    --- Gets the log message.
    function LogEvent:GetMsg()
        return self:GetPrivateField("msg")
    end

    --- Sets the log message.
    function LogEvent:SetMsg(msg)
        if type(msg) ~= "string" then
            return
        end
        self:SetPrivateField("msg", msg)
    end

    --- Gets the precise time.
    function LogEvent:GetTime()
        return self:GetPrivateField("time")
    end

    --- Build a LogEvent.
    -- @param ln Logger name
    -- @param level Level object
    -- @param msg String message
    local function LogEventBuilder(ln, level, msg)
        if type(ln) ~= "string" or not IsLevel(level) then
            return
        end

        return LogEvent(ln, level, osClock(), msg, debugGetInfo(4, "S").source)
    end

    --- The core implementation of the Logger interface.
    -- @type Logger
    local Logger = Object:subclass("Logger")

    function Logger:Initialize(name, context)
        Object.Initialize(self)
        self:SetName(name)
        self:SetPrivateField("ctx", context:GetName())
        self:SetAdditive(true)
    end

    --- Gets the LoggerContext of the Logger.
    -- @param ex True for getting the object, false or nil for getting the name
    -- @return string ctxname
    -- @return object ctx
    function Logger:GetContext(ex)
        if not ex or ex == false then
            return self:GetPrivateField("ctx")
        else
            return _contextDict[self:GetContext()]
        end
    end

    function Logger:__tostring()
        return "Logger: [name:" .. self:GetName() .. "][ctx:" .. self:GetContext() .. "]"
    end

    --- Sets the LoggerConfig name for the Logger.
    -- @param name String name
    function Logger:SetLoggerConfig(name)
        self:SetPrivateField("lc", name)
    end

    function Logger:GetLoggerConfigN()
        return self:GetPrivateField("lc")
    end

    --- Get the LoggerConfig of the Logger.
    -- @return object loggerconfig
    function Logger:GetLoggerConfig()
        return self:GetContext(true):GetConfiguration():GetLoggerConfig(self:GetLoggerConfigN())
    end

    function Logger:SetAdditive(bool)
        if type(bool) ~= "boolean" then
            return
        end
        self:SetPrivateField("additive", bool)
    end

    function Logger:IsAdditive()
        return self:GetPrivateField("additive")
    end

    function Logger:SetLevel(level)
        if not IsLevel(level) then
            return
        end
        self:GetLoggerConfig():SetLevel(level)
    end

    function Logger:GetLevel()
        return self:GetLoggerConfig():GetLevel()
    end

    function Logger:CallAppenders(event, ...)
        if not IsLogEvent(event) then
            return
        end
        local appenders = self:GetLoggerConfig():GetAppenders()
        if not next(appenders) then
            return
        end

        for appender in pairs(appenders) do
            appender:Append(event, ...)
        end
    end

    local function buildEvent(o, level)
        return LogEventBuilder(o:GetName(), getLevel(level))
    end

    --- Construct a log event that will always be logged.
    -- @return object LogEvent
    function Logger:Always()
        return buildEvent(self, "ALL")
    end

    --- Construct a trace log event.
    function Logger:AtTrace()
        return buildEvent(self, "TRACE")
    end

    --- Construct a debug log event.
    function Logger:AtDebug()
        return buildEvent(self, "DEBUG")
    end

    --- Construct a info log event.
    function Logger:AtInfo()
        return buildEvent(self, "INFO")
    end

    --- Construct a warn log event.
    function Logger:AtWarn()
        return buildEvent(self, "WARN")
    end

    --- Construct a error log event.
    function Logger:AtError()
        return buildEvent(self, "ERROR")
    end

    --- Construct a fatal log event.
    function Logger:AtFatal()
        return buildEvent(self, "FATAL")
    end

    --- Logs a message if the specified level is active.
    local function LogIfEnabled(self, level, msg, ...)
        level = getLevel(level)
        if type(msg) ~= "string" or self:GetLevel():IntLevel() < level:IntLevel() then
            return
        end
        self:CallAppenders(LogEventBuilder(self:GetName(), level, msg), ...)
    end

    --- Logs a message with the TRACE level.
    -- @param msg String log message
    -- @param ... Optional vararg to pass to Appender's `Append` method
    function Logger:Trace(msg, ...)
        LogIfEnabled(self, "TRACE", msg, ...)
    end

    --- Logs a message with the DEBUG level.
    -- @param msg String log message
    -- @param ... Optional vararg to pass to Appender's `Append` method
    function Logger:Debug(msg, ...)
        LogIfEnabled(self, "DEBUG", msg, ...)
    end

    --- Logs a message with the INFO level.
    -- @param msg String log message
    -- @param ... Optional vararg to pass to Appender's `Append` method
    function Logger:Info(msg, ...)
        LogIfEnabled(self, "INFO", msg, ...)
    end

    --- Logs a message with the WARN level.
    -- @param msg String log message
    -- @param ... Optional vararg to pass to Appender's `Append` method
    function Logger:Warn(msg, ...)
        LogIfEnabled(self, "WARN", msg, ...)
    end

    --- Logs a message with the ERROR level.
    -- @param msg String log message
    -- @param ... Optional vararg to pass to Appender's `Append` method
    function Logger:Error(msg, ...)
        LogIfEnabled(self, "ERROR", msg, ...)
    end

    --- Logs a message with the FATAL level.
    -- @param msg String log message
    -- @param ... Optional vararg to pass to Appender's `Append` method
    function Logger:Fatal(msg, ...)
        LogIfEnabled(self, "FATAL", msg, ...)
    end

    --- Qualifies the string name of an object and returns if it's a valid name.
    -- @param str String name
    -- @param dot If dots are allowed, default is allowed if param not set
    -- @return bool ifvalid
    local function qualifyName(str, dot)
        if type(str) ~= "string" then
            return false
        end

        if dot == true or dot == nil then
            if str:sub(1, 1) == "." or str:sub(-1) == "." or str:find("[^%a%.]") then
                return false
            end
            local chars = {}

            for i = 1, #str do
                chars[i] = str:sub(i, i)
            end

            for k, v in pairs(chars) do
                if v == "." and (chars[k - 1] == "." or chars[k + 1] == ".") then
                    return false
                end
            end
        else
            if str:find("[^%a]") then
                return false
            end
        end

        return true
    end

    local function createLogger(loggerName, context, loggerconfig)
        if not IsLoggerContext(context) then
            return
        end
        if context:HasLogger(loggerName) or not qualifyName(loggerName) then
            return
        end
        local logger, root = Logger(loggerName, context), getProperty("rootLoggerName", true)

        if loggerName:find("%.") then
            if IsLoggerConfig(loggerconfig) then
                local loggerconfigName = loggerconfig:GetName()

                if loggerconfigName == loggerName then
                    logger:SetLoggerConfig(loggerName)
                else
                    if enumerateAncestors(loggerName)[loggerconfigName] then
                        logger:SetLoggerConfig(loggerconfigName)
                    else
                        logger:SetLoggerConfig(root)
                    end
                end
            else --- Provided 'LoggerConfig' isn't an actual LoggerConfig, automatically assign one.
                local autoLoggerConfigName = loggerName

                while true do
                    if hasLoggerConfig(autoLoggerConfigName, context) then
                        logger:SetLoggerConfig(autoLoggerConfigName)
                        break
                    end

                    autoLoggerConfigName = stripDotExtension(autoLoggerConfigName)

                    if not autoLoggerConfigName:find("%.") and not hasLoggerConfig(autoLoggerConfigName, context) then
                        logger:SetLoggerConfig(root)
                        break
                    end
                end
            end
        else
            if IsLoggerConfig(loggerconfig) and loggerconfig:GetName() == loggerName then
                logger:SetLoggerConfig(loggerName)
            else
                logger:SetLoggerConfig(root)
            end
        end

        context:AddLogger(loggerName, logger)

        return logger
    end

    return createLoggerConfig, createLogger, RootLoggerConfig
end

local createLoggerConfig, createLogger, rootLoggerConfig = initLogger()

return {
    registerProperty = registerProperty,
    getProperty = getProperty,
    getAllProperties = getAllProperties,
    removeProperty = removeProperty,
    createLoggerConfig = createLoggerConfig,
    createLogger = createLogger,
    getLevel = getLevel,
    createLevel = createLevel,
    createConfiguration = createConfiguration,
    getDefaultConfiguration = getDefaultConfiguration,
    createDefaultPatternLayout = createDefaultPatternLayout,
    createConsoleAppender = createConsoleAppender,
    getLoggerCount = getLoggerCount,
    registerContext = registerContext,
    getContext = function(name)
        if type(name) ~= "string" then
            return
        end

        return _contextDict[name]
    end,
    getContextDict = function()
        return _contextDict
    end,
    LogManager = {
        getContext = function(name, withconfig)
            if type(name) ~= "string" then
                return
            end
            local ctx = registerContext(name, withconfig)

            if withconfig or withconfig == nil then
                ctx:SetConfigurationSource(debug.getinfo(2, "S"))
                local rootlc = rootLoggerConfig()
                ctx:GetConfiguration():AddLogger(rootlc:GetName(), rootlc)
                createLogger(rootlc:GetName(), ctx, rootlc)
            end

            return ctx
        end
    }
}
