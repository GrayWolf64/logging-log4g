--- Appends log events to engine console using a layout specified by the user.
-- Subclassing `Appender`.
-- @classmod ConsoleAppender
local Appender = Log4g.GetPkgClsFuncs("log4g-core", "Appender").getClass()
local ConsoleAppender = Appender:subclass("ConsoleAppender")
local TypeUtil = Log4g.GetPkgClsFuncs("log4g-core", "TypeUtil")
local IsLogEvent, IsLayout = TypeUtil.IsLogEvent, TypeUtil.IsLayout
local MsgC = MsgC

function ConsoleAppender:Initialize(name, layout)
    Appender.Initialize(self, name, layout)
end

function ConsoleAppender:Append(event)
    if not IsLogEvent(event) then return end
    local layout = self:GetLayout()
    if not IsLayout(layout) then return end
    MsgC(layout:Format(event))
end

local function CreateConsoleAppender(name, layout)
    return ConsoleAppender(name, layout)
end

Log4g.RegisterPackageClass("log4g-core", "ConsoleAppender", {
    createConsoleAppender = CreateConsoleAppender,
})