# [Log4g](https://github.com/GrayWolf64/gmod-logging-log4g/wiki)

[![Repository Size](https://img.shields.io/github/repo-size/GrayWolf64/gmod-logging-log4g?label=Repository%20Size&style=flat-square)](https://github.com/GrayWolf64/gmod-logging-log4g/)
[![Commit Activity](https://img.shields.io/github/commit-activity/m/GrayWolf64/gmod-logging-log4g?label=Commit%20Activity&style=flat-square)](https://github.com/GrayWolf64/gmod-logging-log4g/graphs/commit-activity)
[![Issues](https://img.shields.io/github/issues/GrayWolf64/gmod-logging-log4g?style=flat-square)](https://github.com/GrayWolf64/gmod-logging-log4g/issues)

[![Last Commit](https://img.shields.io/github/last-commit/GrayWolf64/gmod-logging-log4g)](https://github.com/GrayWolf64/gmod-logging-log4g/)

Log4g is an advanced logging framework for Garry's Mod.

## Currently Work-in-Progress

| Con-Commands    | Usage   | Desc.                                        |
| --------------- | ------- | -------------------------------------------- |
| "Log4g_MMC"     | Console | Monitoring & Management Console (Component)  |
| "Log4g_Version" | Console | Check for Log4g's version                    |

### Component Src Dir

[lua/log4g](https://github.com/GrayWolf64/gmod-logging-log4g/tree/main/lua/log4g)

## How to Add It To Your Project / How to Test?

(not updated)
Simply clone this project and extract the project folder into your `garrysmod/addons` folder.
Then you just have to make sure it loads before your addon, or you can use valid checks:

```lua
--- Check the 'Log4g' global table.
if Log4g then
   --- This will locate / create a proper LoggerContext named 'Foo' with DefaultConfiguration.
   local ctx = Log4g.API.LoggerContextFactory.GetContext("Foo", true)

   --- This will create a new LoggerConfig named 'Calculator' and it to ctx's Configuration, then set its level to DEBUG.
   local lc = Log4g.Core.Config.LoggerConfig.Create("Calculator", ctx:GetConfiguration(), Log4g.Level.GetLevel("TRACE"))

   --- It will add a ConsoleAppender to lc and set its layout to PatternLayout with default settings.
   lc:AddAppender(Log4g.Core.Appender.CreateConsoleAppender("CalcOutput", Log4g.Core.Layout.PatternLayout.CreateDefaultLayout("CalcLayout")))

   --- This will create a Logger named 'Calculate' using lc and add it to ctx.
   local logger = Log4g.GetPkgClsFuncs("log4g-core", "Logger").create("Calculate", ctx, lc)

   for i = 1, 100 do
      --- Do something with i, and log messages.
      -- Note that when this was written, the logging system isn't finished yet,
      -- so I just leave it simple here, for now.

      logger:Debug("Calculated: " .. i .. " times.")
   end
end
```

so that you won't experience errors if your addon is loaded before the logging system.
However, your addon won't successfully log any messages until the logging system is loaded.

## Documentation

The Log4g Documentation is available [here](https://github.com/GrayWolf64/Log4g/wiki).

## Compatibility With Non-GMOD Projects

Some functions need to be replaced in order for this to work.

1. `isstring()`
2. `isbool()`
3. `Color(r, g, b, a)`
4. `table.Count()`
5. ...

## Thanks to Third-party Projects Below

* [Apache Log4j 2](https://github.com/apache/logging-log4j2)
* [MiddleClass](https://github.com/kikito/middleclass)
* [Lua Logging](https://github.com/lunarmodules/lualogging/)
