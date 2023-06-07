--- Appends log events to engine console using a layout specified by the user.
-- Subclassing `Appender`.
-- @classmod ConsoleAppender
local Appender = Log4g.GetPkgClsFuncs("log4g-core", "Appender").getClass()
local ConsoleAppender = Appender:subclass("ConsoleAppender")
local checkClass = include("log4g/core/util/TypeUtil.lua").checkClass
local MsgC = MsgC
local print = print

function ConsoleAppender:Initialize(name, layout)
    Appender.Initialize(self, name, layout)
end

function ConsoleAppender:Append(event)
    if not checkClass(event, "LogEvent") then return end
    local layout = self:GetLayout()
    if not checkClass(layout, "Layout") then return end
    MsgC(layout:Format(event, true))
end

local function CreateConsoleAppender(name, layout)
    return ConsoleAppender(name, layout)
end

Log4g.RegisterPackageClass("log4g-core", "ConsoleAppender", {
    createConsoleAppender = CreateConsoleAppender,
})