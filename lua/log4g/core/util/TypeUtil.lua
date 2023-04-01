local TypeUtil = {}
local pcall = pcall

function TypeUtil.IsLoggerContext(o)
    return pcall(function()
        o:IsLoggerContext()
    end)
end

function TypeUtil.IsSimpleLoggerContext(o)
    return pcall(function()
        o:IsSimpleLoggerContext()
    end)
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