--- Version handler.
-- @script Version
local function getVersionString()
    local verstr = ""

    for k, v in pairs(Log4g.GetAllPackages()) do
        if #verstr == 0 then
            verstr = k .. " " .. v.version
        else
            verstr = verstr .. " " .. k .. " " .. v.version
        end
    end

    return verstr
end

concommand.Add("log4g_version", function()
    print("local version:")
    print(getVersionString())

    http.Fetch("https://raw.githubusercontent.com/GrayWolf64/gmod-logging-log4g/main/VERSION.txt", function(body)
        print("github latest 'VERSION.txt':")
        print(body)
    end, function(msg)
        print(msg)
    end)
end)