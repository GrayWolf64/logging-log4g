--- Client GUI (MMC).
-- @script ClientGUI
-- @license Apache License 2.0
-- @copyright GrayWolf64
local ClientGUIDerma = include("log4g/mmc-gui/client/ClientGUIDerma.lua")
local CreateDFrame = ClientGUIDerma.CreateDFrame
local CreateDListView, CreateDPropertySheet = ClientGUIDerma.CreateDListView, ClientGUIDerma.CreateDPropertySheet
local CreateDPropRow, GetRowControl = ClientGUIDerma.CreateDPropRow, ClientGUIDerma.GetRowControl
local PanelTimedFunc = ClientGUIDerma.PanelTimedFunc
local GetColumnSpecialText, SetProperLineText = ClientGUIDerma.GetColumnSpecialText, ClientGUIDerma.SetProperLineText

CreateClientConVar("Log4g_CL_GUI_UpdateInterval", 5, true, false, nil, 2, 10)
local Frame = nil

concommand.Add("Log4g_MMC", function()
    if IsValid(Frame) then
        Frame:Remove()

        return
    end
    local UpdateInterval = GetConVar("Log4g_CL_GUI_UpdateInterval"):GetInt()
    local function GetGameInfo()
        return "Server: " .. game.GetIPAddress() .. " " .. "SinglePlayer: " .. tostring(game.SinglePlayer())
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

    local function SendEmptyMsgToSV(start)
        net.Start(start)
        net.SendToServer()
    end

    PanelTimedFunc(Icon, UpdateInterval, function() end, function()
        Icon:SetImage("icon16/disconnect.png")
        SendEmptyMsgToSV("Log4g_CLReq_ChkConnected")

        net.Receive("Log4g_CLRcv_ChkConnected", function()
            if not net.ReadBool() then
                return
            end
            Icon:SetImage("icon16/connect.png")
        end)
    end)

    Icon:SetKeepAspect(true)
    Icon:SetSize(16, 16)
    local MenuB = MenuBar:AddMenu("Options")
    MenuB:AddOption("General", function() end):SetIcon("icon16/wrench.png")
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

    for _, v in pairs({ "name", "loggercontext", "level", "appender", "layout" }) do
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

    for _, v in pairs({ "name", "loggercontext" }) do
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
                    }, Line, ListViewB)
                end
            end
        end)
    end)
end)