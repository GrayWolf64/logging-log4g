--- Client GUI (MMC).
-- @script ClientGUI
-- @license Apache License 2.0
-- @copyright GrayWolf64
local ClientGUIDerma = include("log4g/mmc-gui/client/ClientGUIDerma.lua")
local CreateDFrame, CreateDPropertySheet = ClientGUIDerma.CreateDFrame, ClientGUIDerma.CreateDPropertySheet
local CreateDPropRow, GetRowControl = ClientGUIDerma.CreateDPropRow, ClientGUIDerma.GetRowControl
local Frame = nil

concommand.Add("Log4g_MMC", function()
    if IsValid(Frame) then
        Frame:Remove()

        return
    end

    local function GetGameInfo()
        return "Server: " .. game.GetIPAddress() .. " " .. "SinglePlayer: " .. tostring(game.SinglePlayer())
    end

    Frame = CreateDFrame(770, 440, "Log4g Monitoring & Management Console" .. " - " .. GetGameInfo(), "icon16/application.png", nil)
    local MenuBar = vgui.Create("DMenuBar", Frame)
    local MenuA = MenuBar:AddMenu("View")
    local Icon = vgui.Create("DImageButton", MenuBar)
    Icon:Dock(RIGHT)
    Icon:DockMargin(4, 4, 4, 4)

    local function SendEmptyMsgToSV(start)
        net.Start(start)
        net.SendToServer()
    end

    local function UpdateIcon()
        Icon:SetImage("icon16/disconnect.png")
        SendEmptyMsgToSV("Log4g_CLReq_ChkConnected")

        net.Receive("Log4g_CLRcv_ChkConnected", function()
            if not net.ReadBool() then return end
            Icon:SetImage("icon16/connect.png")
        end)
    end

    Icon:SetKeepAspect(true)
    Icon:SetSize(16, 16)
    local BaseSheet = CreateDPropertySheet(Frame, FILL, 0, 1, 0, 0, 4)
    local BasePanel = vgui.Create("DPanel", BaseSheet)
    BasePanel.Paint = nil
    local SummaryPanel = vgui.Create("DPanel", BaseSheet)
    BaseSheet:AddSheet("Summary", SummaryPanel, "icon16/table.png")
    local SummarySheet = vgui.Create("DProperties", SummaryPanel)
    SummarySheet:Dock(FILL)

    local function CreateSpecialRow(category, name)
        local control = GetRowControl(CreateDPropRow(SummarySheet, category, name, "Generic"))
        control:SetEditable(false)

        return control
    end

    local RowA, RowB, RowC, RowD = CreateSpecialRow("Client", "OS Date"), CreateSpecialRow("Server", "Estimated Tickrate"), CreateSpecialRow("Server", "Floored Lua Dynamic RAM Usage (kB)"), CreateSpecialRow("Server", "Entity Count")
    local RowE, RowF, RowG, RowH = CreateSpecialRow("Server", "Networked Entity (EDICT) Count"), CreateSpecialRow("Server", "Net Receiver Count"), CreateSpecialRow("Server", "Lua Registry Table Element Count"), CreateSpecialRow("Server", "Constraint Count")
    local RowI = CreateSpecialRow("Server", "Uptime (Seconds)")

    local function UpdateTime()
        RowA:SetValue(tostring(os.date()))
    end

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
            RowI:SetValue(tostring(net.ReadDouble()))
        end)
    end

    local SheetPanelC = vgui.Create("DPanel", BaseSheet)
    BaseSheet:AddSheet("Configuration", SheetPanelC, "icon16/wrench.png")
    local ConfigFileOption = vgui.Create("DComboBox", SheetPanelC)
    ConfigFileOption:SetWide(300)
    ConfigFileOption:SetPos(2, 2)
    local TextEditor = vgui.Create("DTextEntry", SheetPanelC)
    TextEditor:SetMultiline(true)
    TextEditor:SetSize(748, 325)
    TextEditor:SetPos(2, 26)
    TextEditor:SetDrawLanguageID(false)
    TextEditor:SetFont("Log4gMMCConfigurationFileEditorDefault")
    TextEditor:SetVerticalScrollbarEnabled(true)

    local function ClearTextEditor()
        TextEditor:SetValue("")
        TextEditor:SetEnabled(false)
    end

    local function UpdateConfigurationFilePaths()
        SendEmptyMsgToSV("Log4g_CLReq_SVConfigurationFiles")

        net.Receive("Log4g_CLRcv_SVConfigurationFiles", function()
            ConfigFileOption:Clear()

            for k, v in pairs(net.ReadTable()) do
                ConfigFileOption:AddChoice(k, v)
            end
        end)
    end

    function ConfigFileOption:OnMenuOpened(dmenu)
        self:SetWide(dmenu:GetWide())
    end

    function ConfigFileOption:OnSelect(_, _, data)
        TextEditor:SetText(data)
        if TextEditor:IsEnabled() then return end
        TextEditor:SetEnabled(true)
    end

    local function UpdateGUI()
        UpdateTime()
        UpdateIcon()
        UpdateSummary()
        UpdateConfigurationFilePaths()
        ClearTextEditor()
    end

    MenuA:AddOption("Refresh", function()
        UpdateGUI()
    end):SetIcon("icon16/arrow_refresh.png")

    UpdateGUI()
end)