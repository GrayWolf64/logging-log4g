local GetLevel = Log4g.Level.GetLevel
local GetAppender = Log4g.Core.Appender.GetAppender

Log4g.Core.Config.DefaultConfiguration = {
    NAME = "Default",
    LEVEL = GetLevel("ALL"),
    APPENDER = GetAppender("ConsoleAppender")
}