--- Server-side processing of the Client GUI requests.
-- @script ClientGUI
-- @license Apache License 2.0
-- @copyright GrayWolf64
local LoggerContext = Log4g.GetPkgClsFuncs("log4g-core", "LoggerContext")
local GetAllCtx = LoggerContext.getAll
local GetLoggerCount = LoggerContext.getLoggerCount
local pairs = pairs
local tableCount = table.Count
local tableToJson = util.TableToJSON
local fileRead = file.Read
local getConstraintTable = constraint.GetTable
local netSend, netReceive, netStart = net.Send, net.Receive, net.Start
local netWriteUInt, netWriteBool = net.WriteUInt, net.WriteBool
local netWriteDouble, netWriteFloat = net.WriteDouble, net.WriteFloat
local netWriteString, netWriteData = net.WriteString, net.WriteData
local AddNetworkString = util.AddNetworkString
local Compress = util.Compress

for _, v in pairs({
    [1] = "Log4g_CLReq_ChkConnected",
    [2] = "Log4g_CLRcv_ChkConnected",
    [3] = "Log4g_CLReq_SVSummaryData",
    [4] = "Log4g_CLRcv_SVSummaryData",
    [5] = "Log4g_CLReq_SVConfigurationFiles",
    [6] = "Log4g_CLRcv_SVConfigurationFiles"
}) do
    AddNetworkString(v)
end

--- Write simple compressed data.
-- Must be used between `net.Start()` and `net.Send...`.
-- @param content The content to compress
-- @param bits The number of bits for `net.WriteUInt()` to write the length of compressed binary data
local function WriteDataSimple(content, bits)
    local bindata = Compress(content)
    local len = #bindata
    netWriteUInt(len, bits)
    netWriteData(bindata, len)
end

netReceive("Log4g_CLReq_ChkConnected", function(_, ply)
    netStart("Log4g_CLRcv_ChkConnected", true)
    netWriteBool(IsValid(ply) == ply:IsConnected() == true)
    netSend(ply)
end)

netReceive("Log4g_CLReq_SVSummaryData", function(_, ply)
    netStart("Log4g_CLRcv_SVSummaryData", true)
    netWriteFloat(collectgarbage("count"))
    netWriteUInt(ents.GetCount(), 14)
    netWriteUInt(ents.GetEdictCount(), 13)
    netWriteUInt(tableCount(net.Receivers), 12)
    netWriteUInt(tableCount(debug.getregistry()), 32)
    local constraintCount = 0

    for _, v in pairs(ents.GetAll()) do
        constraintCount = constraintCount + tableCount(getConstraintTable(v))
    end

    netWriteUInt(constraintCount / 2, 16)
    netWriteDouble(SysTime())
    netWriteUInt(tableCount(_G), 32)
    netWriteString(Log4g.API.getCurrentLoggingImpl())
    netWriteUInt(tableCount(GetAllCtx()), 16)
    netWriteUInt(GetLoggerCount(), 16)
    netSend(ply)
end)

netReceive("Log4g_CLReq_SVConfigurationFiles", function(_, ply)
    netStart("Log4g_CLRcv_SVConfigurationFiles", true)
    local map = {}

    for _, v in pairs(GetAllCtx()) do
        local src = v:GetConfigurationSource()

        if src then
            local path = v:GetConfigurationSource().source:sub(2)

            if not map[path] then
                map[path] = fileRead(path, "GAME")
            end
        end
    end

    WriteDataSimple(tableToJson(map), 32)
    netSend(ply)
end)