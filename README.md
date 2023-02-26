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

## Entity Structure

```json
{
   "INSTANCES": [
      {
         "Description": "This is where all the LoggerContexts are stored.",
         "Location": " Local table, in lua/log4g/core/LoggerContext.lua."
      }
      {
         "LoggerContext": {
            {
               "Description": "All the Configuration objects and Loggers are kept in private fields of LoggerContext object."
            },
            "Configuration": [
               {
                  "Description": "All the Appenders and a list of LoggerConfigs' names are here."
               },
               "Appender"
            ],
            "Logger": {
               "LoggerConfig": {
                  "Level"
               }
            }
         }
      }
   ]
}
```

## How to Add It To Your Project / How to Test?

Simply clone this project and extract the project folder into your `garrysmod/addons` folder.
Then you just have to make sure it loads before your addon, or you can use valid checks:

```lua
if Log4g.Core.Logger and Log4g.Core.LoggerContext and Log4g.Level then
   --- Do some calculation here.
   local function Calculate()
      --- This will locate / create a proper LoggerContext for the file where this function is called.
      -- You won't need to create a new one later on the same file,
      -- because using GetContext by providing a function always result in a same LoggerContext.
      -- However, you can just provide a string name instead of a function to have multiple LoggerContext across a single .lua file.
      local ctx = Log4g.API.LoggerContextFactory.GetContext(Calculate)
      Log4g.Core.Logger.Create("Calculate", ctx, Log4g.Level.GetLevel("INFO"))

      for i = 1, 100 do
         --- Do something with i, and log messages.
         -- Note that when this was written, the logging system isn't finished yet,
         -- so I just leave it blank here, for now.
      end
   end
end
```

so that you won't experience errors if your addon is loaded before the logging system.
However, your addon won't successfully log any messages until the logging system is loaded.

## Documentation

The Log4g Documentation is available [here](https://github.com/GrayWolf64/Log4g/wiki).

## Thanks to Third-party Projects Below

* [Apache Log4j 2](https://github.com/apache/logging-log4j2)
* [MiddleClass](https://github.com/kikito/middleclass)
* [Lua Logging](https://github.com/lunarmodules/lualogging/)
