--- Client GUI (MMC).
-- @script ClientGUI
-- @license Apache License 2.0
-- @copyright GrayWolf64
local ClientGUIDerma = include("log4g/mmc-gui/client/ClientGUIDerma.lua")
local CreateDFrame = ClientGUIDerma.CreateDFrame
local CreateDPropertySheet = ClientGUIDerma.CreateDPropertySheet
local CreateDPropRow, GetRowControl = ClientGUIDerma.CreateDPropRow, ClientGUIDerma.GetRowControl
local PanelTimedFunc = ClientGUIDerma.PanelTimedFunc

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

    Frame = CreateDFrame(770, 440, "Log4g Monitoring & Management Console" .. " - " .. GetGameInfo(), "icon16/application.png", nil)
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
    local SheetA = CreateDPropertySheet(Frame, FILL, 0, 1, 0, 0, 4)
    local SheetPanelA = vgui.Create("DPanel", SheetA)
    SheetPanelA.Paint = nil

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
end)