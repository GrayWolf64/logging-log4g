local TypeUtil = {}
local pcall = pcall

function TypeUtil.IsLoggerContext(o, simple)
    if simple == true then
        return pcall(function()
            o:IsSimpleLoggerContext()
        end)
    else
        return pcall(function()
            o:IsLoggerContext()
        end)
    end
end

function TypeUtil.IsLoggerConfig(o, root)
    if root == true then
        return pcall(function()
            o:IsRootLoggerConfig()
        end)
    else
        return pcall(function()
            o:IsLoggerConfig()
        end)
    end
end

function TypeUtil.IsConfiguration(o)
    return pcall(function()
        o:IsConfiguration()
    end)
end

function TypeUtil.IsLevel(o)
    return pcall(function()
        o:IsLevel()
    end)
end

function TypeUtil.IsAppender(o)
    return pcall(function()
        o:IsAppender()
    end)
end

function TypeUtil.IsLogEvent(o)
    return pcall(function()
        o:IsLogEvent()
    end)
end

function TypeUtil.IsLogger(o)
    return pcall(function()
        o:IsLogger()
    end)
end

return TypeUtil