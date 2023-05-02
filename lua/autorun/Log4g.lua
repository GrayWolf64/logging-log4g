if not SERVER then return end
local Log4g = include("log4g/Core.lua")
PrintTable(Log4g)

concommand.Add("log4g_coretest_propertiesPlugin", function()
    local function randomString(len)
        local res = ""

        for i = 1, len do
            res = res .. string.char(math.random(97, 122))
        end

        return res
    end

    local sharedPropertyName, sharedPropertyValue = randomString(10), randomString(10)
    print("creating shared:", sharedPropertyName)
    Log4g.registerProperty(sharedPropertyName, sharedPropertyValue, true)
    PrintTable(Log4g.getAllProperties())
    print("deleting shared:", sharedPropertyName)
    Log4g.removeProperty(sharedPropertyName, true)
    PrintTable(Log4g.getAllProperties())
    print("\n")
    local contextName = randomString(10)
    local privatePropertyName, privatePropertyValue = randomString(10), randomString(10)
    Log4g.registerContext(contextName)
    local context = Log4g.getContext(contextName)
    print("creating private:", privatePropertyName)
    Log4g.registerProperty(privatePropertyName, privatePropertyValue, false, context)
    PrintTable(Log4g.getAllProperties())
    print("deleting private:", privatePropertyName)
    Log4g.removeProperty(privatePropertyName, false, context)
    PrintTable(Log4g.getAllProperties())
    Log4g.getContextDict()[contextName]:Terminate()
end)