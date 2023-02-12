--- Server-side processing of the Client GUI Configurator requests.
-- @script ClientGUIConfigurator
-- @license Apache License 2.0
-- @copyright GrayWolf64
local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl
local RegisterCustomLevel = Log4g.Level.RegisterCustomLevel

local function IdentChk(ply)
    if not IsValid(ply) then return end
    if ply:IsAdmin() then return true end

    return false
end

AddNetworkStrsViaTbl({
    [1] = "Log4g_CLUpload_NewLevel",
    [2] = "Log4g_CLReq_ChkConnected",
    [3] = "Log4g_CLRcv_ChkConnected",
})

net.Receive("Log4g_CLReq_ChkConnected", function(_, ply)
    net.Start("Log4g_CLRcv_ChkConnected")
    net.WriteBool(IsValid(ply) == ply:IsConnected() == true)
    net.Send(ply)
end)

net.Receive("Log4g_CLUpload_NewLevel", function(_, ply)
    if IdentChk(ply) then
        RegisterCustomLevel(net.ReadString(), net.ReadUInt(16))
    end
end)