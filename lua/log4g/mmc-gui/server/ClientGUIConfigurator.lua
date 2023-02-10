--- Server-side processing of the Client GUI Configurator requests.
-- @script ClientGUIConfigurator
-- @license Apache License 2.0
-- @copyright GrayWolf64
local AddNetworkStrsViaTbl = Log4g.Util.AddNetworkStrsViaTbl
local CreateLoggerContext = Log4g.API.LoggerContextFactory.GetContext
local RegisterLoggerConfig = Log4g.Core.Config.LoggerConfig.RegisterLoggerConfig
local RegisterCustomLevel = Log4g.Level.RegisterCustomLevel
local WriteDataSimple = Log4g.Util.WriteDataSimple
local GetLoggerConfig = Log4g.Core.Config.LoggerConfig.Get
local GetLoggerContext = Log4g.Core.LoggerContext.Get

local function IdentChk(ply)
	if not IsValid(ply) then
		return
	end
	if ply:IsAdmin() then
		return true
	end

	return false
end

AddNetworkStrsViaTbl({
	[1] = "Log4g_CLUpload_LoggerConfig_JSON",
	[2] = "Log4g_CLUpload_NewLevel",
	[3] = "Log4g_CLReq_LoggerConfigs",
	[4] = "Log4g_CLRcv_LoggerConfigs",
	[5] = "Log4g_CLReq_LoggerConfig_Remove",
	[6] = "Log4g_CLReq_LoggerConfig_Lookup",
	[7] = "Log4g_CLRcv_LoggerConfig_Lookup",
	[8] = "Log4g_CLReq_LoggerContext_Remove",
	[9] = "Log4g_CLReq_ChkConnected",
	[10] = "Log4g_CLRcv_ChkConnected",
	[11] = "Log4g_CLReq_LoggerContext_Lookup",
	[12] = "Log4g_CLRcv_LoggerContext_Lookup",
})

net.Receive("Log4g_CLReq_ChkConnected", function(_, ply)
	net.Start("Log4g_CLRcv_ChkConnected")
	net.WriteBool(IsValid(ply) == ply:IsConnected() == true)
	net.Send(ply)
end)

net.Receive("Log4g_CLUpload_LoggerConfig_JSON", function(_, ply)
	if not IdentChk(ply) then
		return
	end
	local tbl = util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))
	local contextname = tbl.loggercontext
	CreateLoggerContext(contextname)
	RegisterLoggerConfig(tbl)
end)

local ConfigData = {}
net.Receive("Log4g_CLReq_LoggerConfigs", function(_, ply)
	local tbl = sql.Query("SELECT * FROM Log4g_LoggerConfig")

	net.Start("Log4g_CLRcv_LoggerConfigs")

	if istable(tbl) and not table.IsEmpty(tbl) then
		if ConfigData == tbl then
			net.WriteBool(false)
			return
		end
		ConfigData = tbl
		net.WriteBool(true)
		local data = {}

		for _, v in ipairs(tbl) do
			table.Add(data, { util.JSONToTable(v.Content) })
		end

		WriteDataSimple(util.TableToJSON(data, true), 16)
	else
		net.WriteBool(false)
	end

	net.Send(ply)
end)

net.Receive("Log4g_CLReq_LoggerConfig_Remove", function(_, ply)
	if not IdentChk(ply) then
		return
	end

	GetLoggerConfig(net.ReadString()):Remove()
end)

net.Receive("Log4g_CLReq_LoggerConfig_Lookup", function(_, ply)
	net.Start("Log4g_CLRcv_LoggerConfig_Lookup")

	if sql.QueryRow("SELECT * FROM Log4g_Lookup WHERE Name = 'LoggerConfig';") then
		net.WriteBool(true)
		WriteDataSimple(sql.QueryValue("SELECT Content FROM Log4g_Lookup WHERE Name = 'LoggerConfig';"), 16)
	else
		net.WriteBool(false)
	end

	net.Send(ply)
end)

net.Receive("Log4g_CLReq_LoggerContext_Lookup", function(_, ply)
	net.Start("Log4g_CLRcv_LoggerContext_Lookup")

	if sql.QueryRow("SELECT * FROM Log4g_Lookup WHERE Name = 'LoggerContext';") then
		net.WriteBool(true)
		WriteDataSimple(sql.QueryValue("SELECT Content FROM Log4g_Lookup WHERE Name = 'LoggerContext';"), 16)
	else
		net.WriteBool(false)
	end

	net.Send(ply)
end)

net.Receive("Log4g_CLReq_LoggerContext_Remove", function(_, ply)
	if not IdentChk(ply) then
		return
	end
	GetLoggerContext(net.ReadString()):Terminate()
end)

net.Receive("Log4g_CLUpload_NewLevel", function(_, ply)
	if not IdentChk(ply) then
		return
	end
	RegisterCustomLevel(net.ReadString(), net.ReadUInt(16))
end)
