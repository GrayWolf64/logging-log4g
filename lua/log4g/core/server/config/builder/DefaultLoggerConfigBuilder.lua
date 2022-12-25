local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl
local FindFilesInSubFolders = Log4g.Util.FindFilesInSubFolders

AddNetworkStrsViaTbl({
    ["Log4g_CLReq_LoggerConfig_BuildDefault"] = true
})

net.Receive("Log4g_CLReq_LoggerConfig_BuildDefault", function(len, ply)
    if not ply:IsAdmin() then return end

    for k, v in pairs(FindFilesInSubFolders("log4g/server/loggercontext/", "loggerconfig_*.json", "DATA")) do
        PrintTable(util.JSONToTable(file.Read(v)))
    end
end)