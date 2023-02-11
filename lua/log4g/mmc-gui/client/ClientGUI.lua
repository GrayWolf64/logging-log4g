--- Client GUI (MMC).
-- @script ClientGUI
-- @license Apache License 2.0
-- @copyright GrayWolf64
local ClientGUIDerma = include("log4g/mmc-gui/client/ClientGUIDerma.lua")
local CreateDFrame, CreateDButton = ClientGUIDerma.CreateDFrame, ClientGUIDerma.CreateDButton
local CreateDListView, CreateDPropertySheet = ClientGUIDerma.CreateDListView, ClientGUIDerma.CreateDPropertySheet
local CreateDPropRow, GetRowControl = ClientGUIDerma.CreateDPropRow, ClientGUIDerma.GetRowControl
local GetRowControlValue, PanelTimedFunc = ClientGUIDerma.GetRowControlValue, ClientGUIDerma.PanelTimedFunc
local GetColumnSpecialText, SetProperLineText = ClientGUIDerma.GetColumnSpecialText, ClientGUIDerma.SetProperLineText
local function GetGameInfo()
	return "Server: " .. game.GetIPAddress() .. " " .. "SinglePlayer: " .. tostring(game.SinglePlayer())
end

--- Check if a string has numbers.
-- @lfunction HasNumber
-- @param str The string to check
-- @return bool ifhasnumber
local function HasNumber(str)
	if string.find(str, "%d") then
		return true
	end

	return false
end

--- Send an empty message to the server.
-- This is used as a signal message to tell the server to send another message to client.
-- @lfunction SendEmptyMsgToSV
-- @param start The net msg to start
local function SendEmptyMsgToSV(start)
	net.Start(start)
	net.SendToServer()
end

CreateClientConVar(
	"Log4g_CL_GUI_ElementUpdateInterval",
	5,
	true,
	false,
	"Client GUI elements will be updated every given seconds (between 2 and 10).",
	2,
	10
)
local Frame = nil

concommand.Add("Log4g_MMC", function()
	local UpdateInterval = GetConVar("Log4g_CL_GUI_ElementUpdateInterval"):GetInt()

	if IsValid(Frame) then
		Frame:Remove()

		return
	end

	Frame = CreateDFrame(
		770,
		440,
		"Log4g Monitoring & Management Console" .. " - " .. GetGameInfo(),
		"icon16/application.png",
		nil
	)
	local MenuBar = vgui.Create("DMenuBar", Frame)
	local Icon = vgui.Create("DImageButton", MenuBar)
	Icon:Dock(RIGHT)
	Icon:DockMargin(4, 4, 4, 4)

	PanelTimedFunc(Icon, UpdateInterval, function() end, function()
		Icon:SetImage("icon16/disconnect.png")
		SendEmptyMsgToSV("Log4g_CLReq_ChkConnected")

		net.Receive("Log4g_CLRcv_ChkConnected", function()
			if net.ReadBool() ~= true then
				return
			end
			Icon:SetImage("icon16/connect.png")
		end)
	end)

	Icon:SetKeepAspect(true)
	Icon:SetSize(16, 16)
	local MenuA = MenuBar:AddMenu("New")
	local MenuB = MenuBar:AddMenu("Options")
	MenuB:AddOption("General", function() end):SetIcon("icon16/wrench.png")
	local MenuC = MenuBar:AddMenu("Help")
	local SheetA = CreateDPropertySheet(Frame, FILL, 0, 1, 0, 0, 4)
	local SheetPanelA = vgui.Create("DPanel", SheetA)
	SheetPanelA.Paint = nil
	SheetA:AddSheet("Configuration", SheetPanelA, "icon16/cog.png")
	local SheetB = CreateDPropertySheet(SheetPanelA, FILL, 0, 0, 0, 0, 4)
	local SheetPanelB = vgui.Create("DPanel", SheetB)
	SheetB:AddSheet("LoggerConfig", SheetPanelB)
	local ListView = CreateDListView(SheetPanelB, LEFT, 0, 0, 0, 0, 18, 18.5)
	ListView:SetWide(600)
	local Tree = vgui.Create("DTree", SheetPanelB)
	Tree:Dock(RIGHT)
	Tree:SetWide(140)
	Tree:DockMargin(0, 0, 0, 0)

	for _, v in pairs({ "name", "loggercontext", "level", "appender", "layout", "logmsg" }) do
		ListView:AddColumn(v)
	end

	--- Start a special net msg for ListView's line behaviour after being clicked on.
	-- @lfunction NetStrMsgSpecial
	-- @param num The number of the line
	-- @param listview The DListView containing the line
	-- @param start The net msg to start
	-- @param ... The texts of the specific column headers
	local function NetStrMsgSpecial(num, listview, start, ...)
		local args = { ... }

		local result = GetColumnSpecialText(num, listview, unpack(args))
		net.Start(start)

		for _, v in ipairs(args) do
			net.WriteString(result[v])
		end

		net.SendToServer()
	end

	function ListView:OnRowRightClick(num)
		local Menu = DermaMenu()
		local SubA = Menu:AddSubMenu("Build")

		SubA:AddOption("Default", function()
			NetStrMsgSpecial(num, ListView, "Log4g_CLReq_LoggerConfig_BuildDefault", "name")
		end)

		Menu:AddSpacer()

		Menu:AddOption("Remove", function()
			NetStrMsgSpecial(num, ListView, "Log4g_CLReq_LoggerConfig_Remove", "name")
		end):SetIcon("icon16/cross.png")

		Menu:Open()
	end

	PanelTimedFunc(ListView, UpdateInterval, function() end, function()
		SendEmptyMsgToSV("Log4g_CLReq_LoggerConfigs")

		net.Receive("Log4g_CLRcv_LoggerConfigs", function()
			ListView:Clear()
			if net.ReadBool() then
				for _, v in ipairs(util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))) do
					local Line = ListView:AddLine()
					SetProperLineText(v, Line, ListView)
				end
			end
		end)
	end)

	local SheetPanelBA = vgui.Create("DPanel", SheetB)
	SheetB:AddSheet("LoggerContext", SheetPanelBA)
	local ListViewC = vgui.Create("DListView", SheetPanelBA)
	ListViewC:Dock(FILL)
	for _, v in pairs({ "name" }) do
		ListViewC:AddColumn(v)
	end
	function ListViewC:OnRowRightClick(num)
		local Menu = DermaMenu()

		Menu:AddOption("Terminate", function()
			NetStrMsgSpecial(num, ListViewC, "Log4g_CLReq_LoggerContext_Terminate", "name")
		end):SetIcon("icon16/cross.png")

		Menu:Open()
	end
	PanelTimedFunc(ListViewC, UpdateInterval, function() end, function()
		SendEmptyMsgToSV("Log4g_CLReq_LoggerContext_Lookup")

		net.Receive("Log4g_CLRcv_LoggerContext_Lookup", function()
			ListViewC:Clear()
			if net.ReadBool() then
				for k, _ in pairs(util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))) do
					ListViewC:AddLine(k)
				end
			end
		end)
	end)

	local SubB = MenuB:AddSubMenu("View")
	SubB:SetDeleteSelf(false)

	SubB:AddOption("Clear", function()
		ListView:Clear()
		Tree:Clear()
	end):SetIcon("icon16/application_form_delete.png")

	SubB:AddOption("Update Frequency", function()
		local Window = CreateDFrame(300, 75, "Change...", "icon16/application.png", Frame)
		local Slider = vgui.Create("DNumSlider", Window)
		Slider:Dock(FILL)
		Slider:SetText("GUI Update Frequency")
		Slider:SetMin(2)
		Slider:SetMax(10)
		Slider:SetDecimals(0)
		Slider:SetConVar("Log4g_CL_GUI_ElementUpdateInterval")
		Window:SetDrawOnTop(true)
	end):SetIcon("icon16/clock_edit.png")

	PanelTimedFunc(Tree, UpdateInterval, function() end, function()
		SendEmptyMsgToSV("Log4g_CLReq_LoggerConfig_Lookup")

		net.Receive("Log4g_CLRcv_LoggerConfig_Lookup", function()
			Tree:Clear()
			if net.ReadBool() then
				for k, _ in pairs(util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))) do
					Tree:AddNode(k, "icon16/brick.png")
				end
			end
		end)
	end)

	local SubMenuB = MenuA:AddSubMenu("Configuration")
	SubMenuB:SetDeleteSelf(false)

	SubMenuB:AddOption("LoggerConfig JSON Wizard", function()
		local Window = CreateDFrame(400, 300, "New LoggerConfig", "icon16/application_lightning.png", Frame)
		local Entry = vgui.Create("DTextEntry", Window)
		Entry:SetMultiline(true)
		Entry:Dock(FILL)
		local ButtonA = CreateDButton(Window, BOTTOM, 150, 0, 150, 0, 100, 50, "Submit")

		ButtonA.DoClick = function()
			local Content = Entry:GetValue()
			if #Content == 0 or not isstring(Content) then
				return
			end
			net.Start("Log4g_CLUpload_LoggerConfig_JSON")
			local Data = util.Compress(Content)
			local Len = #Data
			net.WriteUInt(Len, 16)
			net.WriteData(Data, Len)
			net.SendToServer()
			Window:Close()
		end
	end):SetIcon("icon16/cog_add.png")

	SubMenuB:AddOption("Level", function()
		local Window = CreateDFrame(300, 150, "New Level", "icon16/application.png", Frame)
		Window:SetDrawOnTop(true)
		local DProp = vgui.Create("DProperties", Window)
		DProp:Dock(FILL)
		local RowA, RowB =
			DPropNewRow(DProp, "Self", "Name", "Generic"), DPropNewRow(DProp, "Self", "IntLevel", "Generic")
		local ButtonB = CreateDButton(Window, BOTTOM, 100, 0, 100, 0, 100, 50, "Submit")

		ButtonB.DoClick = function()
			local InputName = GetRowControlValue(RowA)
			local InputInt = GetRowControlValue(RowB)
			if HasNumber(InputName) or #InputName == 0 or #InputInt == 0 then
				return
			end
			net.Start("Log4g_CLUpload_NewLevel")
			net.WriteString(InputName)
			net.WriteUInt(tonumber(InputInt), 16)
			net.SendToServer()
			Window:Close()
		end
	end):SetIcon("icon16/chart_bar.png")

	MenuC:AddOption("About", function()
		local Window = CreateDFrame(300, 125, "About", "icon16/information.png", Frame)
		Window:SetDrawOnTop(true)
		local Text = vgui.Create("RichText", Window)
		Text:Dock(FILL)
		Text:InsertColorChange(192, 192, 192, 255)

		for _, v in ipairs({
			"Log4g is an open-source addon for Garry's Mod.\n",
			"\n",
			"GitHub Page: https://github.com/GrayWolf64/gmod-logging-log4g\n",
			"\n",
			"Documentation can be seen on GitHub Page as well.\n",
		}) do
			Text:AppendText(v)
		end
	end):SetIcon("icon16/information.png")

	local SheetPanelC = vgui.Create("DPanel", SheetA)
	SheetA:AddSheet("Overview (SV)", SheetPanelC, "icon16/page.png")
	local SheetPanelD = vgui.Create("DPanel", SheetA)
	SheetA:AddSheet("Summary", SheetPanelD, "icon16/table.png")
	local SummarySheet = vgui.Create("DProperties", SheetPanelD)
	SummarySheet:Dock(FILL)

	--- Create a row with a Generic RowControl which users can't type into inside SummarySheet.
	local function CreateSpecialRow(category, name)
		local control = GetRowControl(CreateDPropRow(SummarySheet, category, name, "Generic"))
		control:SetEditable(false)
		return control
	end

	local RowA, RowB, RowC, RowD =
		CreateSpecialRow("Client", "OS Date"),
		CreateSpecialRow("Server", "Estimated Tickrate"),
		CreateSpecialRow("Server", "Floored Lua Dynamic RAM Usage (kB)"),
		CreateSpecialRow("Server", "Entity Count")
	local RowE, RowF, RowG, RowH =
		CreateSpecialRow("Server", "Networked Entity (EDICT) Count"),
		CreateSpecialRow("Server", "Net Receiver Count"),
		CreateSpecialRow("Server", "Lua Registry Table Element Count"),
		CreateSpecialRow("Server", "Constraint Count")

	local function UpdateSummary()
		SendEmptyMsgToSV("Log4g_CLReq_SVSummaryData")

		net.Receive("Log4g_CLRcv_SVSummaryData", function()
			RowB:SetValue(tostring(1 / engine.ServerFrameTime()))
			RowC:SetValue(tostring(net.ReadFloat()))
			RowD:SetValue(tostring(net.ReadUInt(14)))
			RowE:SetValue(tostring(net.ReadUInt(13)))
			RowF:SetValue(tostring(net.ReadUInt(12)))
			RowG:SetValue(tostring(net.ReadUInt(32)))
			RowH:SetValue(tostring(net.ReadUInt(16)))
		end)
	end

	PanelTimedFunc(SummarySheet, UpdateInterval, function()
		RowA:SetValue(tostring(os.date()))
	end, function()
		UpdateSummary()
	end)

	UpdateSummary()
	local SheetPanelE = vgui.Create("DPanel", SheetA)
	SheetA:AddSheet("LOGGER", SheetPanelE, "icon16/brick.png")
	local ListViewB = CreateDListView(SheetPanelE, FILL, 0, 0, 0, 0, 18, 18.5)

	for _, v in pairs({ "name", "loggercontext", "configfile" }) do
		ListViewB:AddColumn(v)
	end

	function ListViewB:OnRowRightClick(num)
		local Menu = DermaMenu()

		Menu:AddOption("Terminate", function()
			NetStrMsgSpecial(num, ListViewB, "Log4g_CLReq_Logger_Remove", "loggercontext", "name")
		end):SetIcon("icon16/cross.png")

		Menu:Open()
	end

	PanelTimedFunc(ListViewB, UpdateInterval, function() end, function()
		SendEmptyMsgToSV("Log4g_CLReq_Logger_Lookup")

		net.Receive("Log4g_CLRcv_Logger_Lookup", function()
			ListViewB:Clear()
			if net.ReadBool() then
				for k, v in pairs(util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))) do
					local Line = ListViewB:AddLine()

					SetProperLineText({
						name = k,
						loggercontext = v.loggercontext,
						configfile = v.configfile,
					}, Line, ListViewB)
				end
			end
		end)
	end)
end)
