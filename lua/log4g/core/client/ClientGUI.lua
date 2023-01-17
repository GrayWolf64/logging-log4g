--- Client GUI (MMC).
-- @script ClientGUI.lua
-- @license Apache License 2.0
-- @copyright GrayWolf64
local function CreateDFrame(a, b, title, icon, parent)
    local dframe = vgui.Create("DFrame")
    dframe:MakePopup()
    dframe:SetSize(a, b)
    dframe:Center()
    dframe:SetScreenLock(true)
    dframe:SetTitle(title)
    dframe:SetIcon(icon)

    if IsValid(parent) then
        dframe:SetParent(parent)
    end

    return dframe
end

local function AppendRichTextViaTbl(panel, tbl)
    for _, v in ipairs(tbl) do
        if not isstring(v) then return end
        panel:AppendText(v)
    end
end

local function CreateDButton(parent, docktype, x, y, z, w, a, b, text)
    local dbutton = vgui.Create("DButton", parent)
    dbutton:Dock(docktype)
    dbutton:DockMargin(x, y, z, w)
    dbutton:SetSize(a, b)
    dbutton:SetText(text)

    return dbutton
end

local function CreateDHDivider(parent, left, right, width, lmin, rmin)
    local dhdivider = vgui.Create("DHorizontalDivider", parent)
    dhdivider:Dock(FILL)
    dhdivider:SetLeft(left)
    dhdivider:SetRight(right)
    dhdivider:SetDividerWidth(width)
    dhdivider:SetLeftMin(lmin)
    dhdivider:SetRightMin(rmin)
end

local function CreateDListView(parent, docktype, x, y, z, w)
    local dlistview = vgui.Create("DListView", parent)
    dlistview:SetMultiSelect(false)
    dlistview:Dock(docktype)
    dlistview:DockMargin(x, y, z, w)

    return dlistview
end

--- Create a new row in a DProp.
-- @lfunction DPropNewRow
-- @param panel The DProp
-- @param category The category to put the row into
-- @param name The label of the row
-- @param prop The name of RowControl to add
-- @return row created row
local function DPropNewRow(panel, category, name, prop)
    local row = panel:CreateRow(category, name)
    row:Setup(prop)

    return row
end

--- Get a row's RowControl.
-- Because the official way to obtain a RowControl doesn't exist, we have to go this way.
-- @lfunction GetRowControl
-- @param row The row to get the RowControl from
-- @return row obtained row
local function GetRowControl(row)
    return row:GetChild(1):GetChild(0):GetChild(0)
end

--- Get a RowControl's value (edited by user) whether it's a DTextEntry or a DComboBox.
-- @lfunction GetRowControlValue
-- @param row The row in the DProp Panel
-- @return string value obtained
local function GetRowControlValue(row)
    local pnl = GetRowControl(row)
    local class = pnl:GetName()

    if class == "DTextEntry" then
        return pnl:GetValue()
    elseif class == "DComboBox" then
        return pnl:GetSelected()
    end
end

local function GetGameInfo()
    return "Server: " .. game.GetIPAddress() .. " " .. "SinglePlayer: " .. tostring(game.SinglePlayer())
end

--- Check if a string has numbers.
-- @lfunction HasNumber
-- @param str The string to check
-- @return bool ifhasnumber
local function HasNumber(str)
    if string.find(str, "%d") then return true end

    return false
end

--- In a Panel's Think, run a function and run another function but timed.
-- @lfunction PanelTimedFunc
-- @param panel The Panel which has a Think function to override
-- @param interval The function will run every given seconds
-- @param funca The first function
-- @param funcb The second function
local function PanelTimedFunc(panel, interval, funca, funcb)
    local prevtime = os.time()

    function panel:Think()
        funca()
        local prestime = os.time()
        if prevtime + interval > prestime then return end
        funcb()
        prevtime = prevtime + interval
    end
end

CreateClientConVar("Log4g_CL_GUI_ElementUpdateInterval", 5, true, false, "Client GUI elements will be updated every given seconds (between 2 and 10).", 2, 10)
local Frame = nil

concommand.Add("Log4g_MMC", function()
    local UpdateInterval = GetConVar("Log4g_CL_GUI_ElementUpdateInterval"):GetInt()

    if IsValid(Frame) then
        Frame:Remove()

        return
    end

    Frame = CreateDFrame(900, 540, "Log4g Monitoring & Management Console" .. " - " .. GetGameInfo(), "icon16/application.png", nil)
    local MenuBar = vgui.Create("DMenuBar", Frame)
    local Icon = vgui.Create("DImageButton", MenuBar)
    Icon:Dock(RIGHT)
    Icon:DockMargin(4, 4, 4, 4)

    PanelTimedFunc(Icon, UpdateInterval, function() end, function()
        Icon:SetImage("icon16/disconnect.png")
        net.Start("Log4g_CL_ChkConnected")
        net.SendToServer()

        net.Receive("Log4g_CL_IsConnected", function()
            if net.ReadBool() ~= true then return end
            Icon:SetImage("icon16/connect.png")
        end)
    end)

    Icon:SetKeepAspect(true)
    Icon:SetSize(16, 16)
    local MenuA = MenuBar:AddMenu("New")
    local MenuB = MenuBar:AddMenu("Options")
    MenuB:AddOption("General", function() end):SetIcon("icon16/wrench.png")
    local MenuC = MenuBar:AddMenu("Help")
    local SheetA = vgui.Create("DPropertySheet", Frame)
    SheetA:Dock(FILL)
    SheetA:DockMargin(1, 1, 1, 1)
    SheetA:SetPadding(4)
    local SheetPanelA = vgui.Create("DPanel", SheetA)
    SheetPanelA.Paint = nil
    SheetA:AddSheet("Configuration", SheetPanelA, "icon16/cog.png")
    local SheetB = vgui.Create("DPropertySheet", SheetPanelA)
    SheetB:Dock(FILL)
    SheetB:DockMargin(1, 1, 1, 1)
    SheetB:SetPadding(4)
    local SheetPanelB = vgui.Create("DPanel", SheetB)
    SheetB:AddSheet("LoggerConfig", SheetPanelB)
    local ListView = CreateDListView(SheetPanelB, LEFT, 1, 1, 1, 0)
    ListView:SetHeaderHeight(18)
    ListView:SetDataHeight(18.5)
    local Tree = vgui.Create("DTree", SheetPanelB)
    Tree:Dock(RIGHT)
    Tree:DockMargin(1, 1, 1, 0)
    net.Start("Log4g_CLReq_LoggerConfig_Keys")
    net.SendToServer()

    net.Receive("Log4g_CLRcv_LoggerConfig_Keys", function()
        for _, v in pairs(net.ReadTable()) do
            ListView:AddColumn(v):SetFixedWidth(90)
        end
    end)

    --- Get a line's content text at specific columns.
    -- There's not an official way to do this, so GetChild can be used here.
    -- @lfunction GetColumnSpecialText
    -- @param num The number of the line
    -- @param listview The DListView containing the line
    -- @param ... The texts of the specific columns
    -- @return tbl results
    local function GetColumnSpecialText(num, listview, ...)
        local line = listview:GetLine(num)
        if not IsValid(line) then return end

        local tbl, args = {}, {...}

        for m, n in ipairs(listview.Columns) do
            local text = n:GetChild(0):GetText()
            local str = line:GetColumnText(m)

            for _, v in pairs(args) do
                if v == text then
                    tbl[text] = str
                end
            end
        end

        return tbl
    end

    --- Set a DListView's line's text correctly using the given table with string keys and string values.
    -- @lfunction SetProperLineText
    -- @param tbl The table containing the needed text values, and its keys must be the same with the column texts
    -- @param line The line to set the texts in
    local function SetProperLineText(tbl, line, listview)
        for i, j in pairs(tbl) do
            for m, n in ipairs(listview.Columns) do
                if i == n:GetChild(0):GetText() then
                    line:SetColumnText(m, j)
                end
            end
        end
    end

    PanelTimedFunc(ListView, UpdateInterval, function()
        function ListView:OnRowRightClick(num)
            local Menu = DermaMenu()
            local SubA = Menu:AddSubMenu("Build (SV)")

            SubA:AddOption("Default", function()
                local tbl = GetColumnSpecialText(num, ListView, "loggercontext", "name")
                net.Start("Log4g_CLReq_LoggerConfig_BuildDefault")
                net.WriteString(tbl["loggercontext"])
                net.WriteString(tbl["name"])
                net.SendToServer()
            end)

            Menu:AddSpacer()

            Menu:AddOption("Remove", function()
                local tbl = GetColumnSpecialText(num, ListView, "loggercontext", "name")
                net.Start("Log4g_CLReq_LoggerConfig_Remove")
                net.WriteString(tbl["loggercontext"])
                net.WriteString(tbl["name"])
                net.SendToServer()
            end):SetIcon("icon16/cross.png")

            Menu:Open()
        end
    end, function()
        ListView:Clear()
        net.Start("Log4g_CLReq_LoggerConfigs")
        net.SendToServer()

        net.Receive("Log4g_CLRcv_LoggerConfigs", function()
            for _, v in ipairs(util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))) do
                local Line = ListView:AddLine()
                SetProperLineText(v, Line, ListView)
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

    PanelTimedFunc(Tree, UpdateInterval, function()
        function Tree:DoRightClick(node)
            if node:GetIcon() ~= "icon16/folder.png" then return end
            local Menu = DermaMenu()

            Menu:AddOption("Remove", function()
                if not IsValid(node) then return end
                net.Start("Log4g_CLReq_LoggerContext_Remove")
                net.WriteString(node:GetText())
                net.SendToServer()
            end):SetIcon("icon16/cross.png")

            Menu:Open()
        end
    end, function()
        Tree:Clear()
        net.Start("Log4g_CLReq_LoggerContext_Lookup")
        net.SendToServer()

        net.Receive("Log4g_CLRcv_LoggerContext_Lookup", function()
            if not net.ReadBool() then return end
            local Tbl = util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))

            for k, v in pairs(Tbl) do
                local Node = Tree:AddNode(k, "icon16/folder.png")
                Node:SetExpanded(true)

                for _, j in pairs(v) do
                    Node:AddNode(j, "icon16/brick.png")
                end
            end
        end)
    end)

    local SubMenuB = MenuA:AddSubMenu("Configuration")
    SubMenuB:SetDeleteSelf(false)

    SubMenuB:AddOption("LoggerConfig", function()
        local Window = CreateDFrame(400, 300, "New LoggerConfig", "icon16/application_view_list.png", Frame)
        local DProp = vgui.Create("DProperties", Window)
        DProp:Dock(FILL)
        local RowA, RowB = DPropNewRow(DProp, "Hook", "Event Name", "Combo"), DPropNewRow(DProp, "Hook", "Unique Identifier", "Generic")
        local RowC, RowD = DPropNewRow(DProp, "Logger", "LoggerContext", "Generic"), DPropNewRow(DProp, "Logger", "Level", "Combo")
        local RowE, RowF = DPropNewRow(DProp, "Logger", "Appender", "Combo"), DPropNewRow(DProp, "Logger", "Layout", "Combo")
        local RowG, RowH = DPropNewRow(DProp, "Self", "LoggerConfig Name", "Generic"), DPropNewRow(DProp, "Logger", "Function", "Generic")
        net.Start("Log4g_CLReq_Hooks")
        net.SendToServer()

        net.Receive("Log4g_CLRcv_Hooks", function()
            for k, _ in pairs(util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))) do
                RowA:AddChoice(tostring(k))
            end
        end)

        --- Receive a Net table and add the given choices to a RowControl's DComboBox.
        -- @lfunction AddChoiceViaNetTbl
        -- @param start The message to request the server to send another Net message
        -- @param receive The message containing the table to receive
        -- @param row The row containing the DComboBox
        local function AddChoiceViaNetTbl(start, receive, row)
            local box = GetRowControl(row)
            box:Clear()
            net.Start(start)
            net.SendToServer()

            net.Receive(receive, function()
                for _, v in pairs(net.ReadTable()) do
                    box:AddChoice(v)
                end
            end)

            box:SetValue("Select...")
        end

        function Window:OnCursorEntered()
            net.Start("Log4g_CL_PendingTransmission_DPropLoggerConfigMessages")
            net.SendToServer()
            AddChoiceViaNetTbl("Log4g_CLReq_Levels", "Log4g_CLRcv_Levels", RowD)
            AddChoiceViaNetTbl("Log4g_CLReq_Appenders", "Log4g_CLRcv_Appenders", RowE)
            AddChoiceViaNetTbl("Log4g_CLReq_Layouts", "Log4g_CLRcv_Layouts", RowF)
        end

        local ButtonA = CreateDButton(Window, BOTTOM, 150, 0, 150, 0, 100, 50, "Submit")

        ButtonA.DoClick = function()
            local InputName = GetRowControlValue(RowG)
            local InputLoggerContextName = GetRowControlValue(RowC)
            if HasNumber(InputName) or HasNumber(InputLoggerContextName) or #InputName == 0 or #InputLoggerContextName == 0 then return end
            net.Start("Log4g_CLUpload_LoggerConfig")

            net.WriteTable({
                name = string.lower(InputName),
                eventname = GetRowControlValue(RowA),
                uid = GetRowControlValue(RowB),
                loggercontext = string.lower(InputLoggerContextName),
                level = GetRowControlValue(RowD),
                appender = GetRowControlValue(RowE),
                layout = GetRowControlValue(RowF),
                func = GetRowControlValue(RowH)
            })

            net.SendToServer()
            Window:Close()
        end
    end):SetIcon("icon16/cog_add.png")

    SubMenuB:AddOption("Level", function()
        local Window = CreateDFrame(300, 150, "New Level", "icon16/application.png", Frame)
        Window:SetDrawOnTop(true)
        local DProp = vgui.Create("DProperties", Window)
        DProp:Dock(FILL)
        local RowA, RowB = DPropNewRow(DProp, "Self", "Name", "Generic"), DPropNewRow(DProp, "Self", "IntLevel", "Generic")
        local ButtonB = CreateDButton(Window, BOTTOM, 100, 0, 100, 0, 100, 50, "Submit")

        ButtonB.DoClick = function()
            local InputName = GetRowControlValue(RowA)
            local InputInt = GetRowControlValue(RowB)
            if HasNumber(InputName) or #InputName == 0 or #InputInt == 0 then return end
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

        AppendRichTextViaTbl(Text, {
            [1] = "Log4g is an open-source addon for Garry's Mod.\n",
            [2] = "\n",
            [3] = "GitHub Page: https://github.com/GrayWolf64/gmod-logging-log4g\n",
            [4] = "\n",
            [5] = "Documentation can be seen on GitHub Page as well.\n"
        })
    end):SetIcon("icon16/information.png")

    CreateDHDivider(SheetPanelB, ListView, Tree, 4, 720, 120)
    local SheetPanelC = vgui.Create("DPanel", SheetA)
    SheetA:AddSheet("Overview (SV)", SheetPanelC, "icon16/page.png")
    local SheetPanelD = vgui.Create("DPanel", SheetA)
    SheetA:AddSheet("Summary", SheetPanelD, "icon16/table.png")
    local SummarySheet = vgui.Create("DProperties", SheetPanelD)
    SummarySheet:Dock(FILL)

    --- Create a row with a Generic RowControl which users can't type into.
    -- @lfunction CreateSpecialRow
    -- @param dprop The DProperties to create the row in
    -- @param category The category to put the row into
    -- @param name The label of the row
    -- @return row created row
    local function CreateSpecialRow(dprop, category, name)
        local row = dprop:CreateRow(category, name)
        row:Setup("Generic")
        GetRowControl(row):SetEditable(false)

        return row
    end

    local RowA, RowB = CreateSpecialRow(SummarySheet, "Client", "OS Date"), CreateSpecialRow(SummarySheet, "Server", "Estimated Tickrate")
    local RowC, RowD = CreateSpecialRow(SummarySheet, "Server", "Floored Lua Dynamic RAM Usage (kB)"), CreateSpecialRow(SummarySheet, "Server", "Entity Count")
    local RowE, RowF = CreateSpecialRow(SummarySheet, "Server", "Networked Entity (EDICT) Count"), CreateSpecialRow(SummarySheet, "Server", "Net Receiver Count")
    local RowG, RowH = CreateSpecialRow(SummarySheet, "Server", "Lua Registry Table Element Count"), CreateSpecialRow(SummarySheet, "Server", "Constraint Count")

    local function UpdateSummary()
        net.Start("Log4g_CLReq_SVSummaryData")
        net.SendToServer()

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