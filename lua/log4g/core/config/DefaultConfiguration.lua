local Accessor = Log4g.Core.Config
Accessor.DEFAULT_NAME = "Default"
local Configuration = Log4g.Core.Config.Configuration.GetClass()
local DefaultConfiguration = Configuration:subclass("DefaultConfiguration")

function DefaultConfiguration:Initialize(name)
    Configuration.Initialize(self)
    self.name = name
end

function Accessor.GetDefaultConfiguration()
    return DefaultConfiguration(Accessor.DEFAULT_NAME)
end