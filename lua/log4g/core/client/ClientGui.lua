--- Client GUI (MMC).
-- @script ClientGUI.lua
local function CreateDFrame(a, b, title, icon)
    local dframe = vgui.Create("DFrame")
    dframe:MakePopup()
    dframe:SetSize(a, b)
    dframe:Center()
    dframe:SetScreenLock(true)
    dframe:SetTitle(title)
    dframe:SetIcon(icon)
    dframe:SetDrawOnTop(true)

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
-- @return row The created row
local function DPropNewRow(panel, category, name, prop)
    local row = panel:CreateRow(category, name)
    row:Setup(prop)

    return row
end

--- Get a RowControl's value (edited by user) whether it's a DTextEntry or a DComboBox.
-- @lfunction GetRowControlValue
-- @param row The row in the DProp Panel
-- @return string The value obtained
local function GetRowControlValue(row)
    local pnl = row:GetChild(1):GetChild(0):GetChild(0)
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

local UpdateInterval = CreateClientConVar("Log4g_CL_GUI_ElementUpdateInterval", 5, true, false, "Client GUI elements will be updated every given seconds (at least 1).", 1):GetInt()

concommand.Add("Log4g_MMC", function()
    local FrameA = CreateDFrame(960, 640, "Log4g Monitoring & Management Console(MMC)" .. " - " .. GetGameInfo(), "icon16/application.png")
    local MenuBar = vgui.Create("DMenuBar", FrameA)
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
    local MenuB = MenuBar:AddMenu("Settings")
    MenuB:AddOption("General", function() end):SetIcon("icon16/wrench.png")
    local MenuC = MenuBar:AddMenu("Help")
    local SheetA = vgui.Create("DPropertySheet", FrameA)
    SheetA:Dock(FILL)
    SheetA:DockMargin(1, 1, 1, 1)
    SheetA:SetPadding(5)
    local SheetPanelA = vgui.Create("DPanel", SheetA)

    function SheetPanelA:Paint()
        return
    end

    SheetA:AddSheet("Configuration", SheetPanelA, "icon16/cog.png")
    local SheetB = vgui.Create("DPropertySheet", SheetPanelA)
    SheetB:Dock(FILL)
    SheetB:DockMargin(1, 1, 1, 1)
    SheetB:SetPadding(5)
    local SheetPanelB = vgui.Create("DPanel", SheetB)
    SheetB:AddSheet("LoggerConfig", SheetPanelB)
    local ListView = CreateDListView(SheetPanelB, LEFT, 1, 1, 1, 0)
    ListView:SetDataHeight(18)
    local Tree = vgui.Create("DTree", SheetPanelB)
    Tree:Dock(RIGHT)
    Tree:DockMargin(1, 1, 1, 0)
    net.Start("Log4g_CLReq_LoggerConfig_Keys")
    net.SendToServer()

    net.Receive("Log4g_CLRcv_LoggerConfig_Keys", function()
        for _, v in pairs(net.ReadTable()) do
            ListView:AddColumn(v)
        end
    end)

    PanelTimedFunc(ListView, UpdateInterval, function()
        function ListView:OnRowRightClick(num)
            local Menu = DermaMenu()

            Menu:AddOption("Remove", function()
                net.Start("Log4g_CLReq_LoggerConfig_Remove")
                local Line = ListView:GetLine(num)
                local LoggerContextName, LoggerConfigName

                for m, n in ipairs(ListView.Columns) do
                    local Text = n:GetChild(0):GetText()
                    local Str = Line:GetColumnText(m)

                    if Text == "loggercontext" then
                        LoggerContextName = Str
                    elseif Text == "name" then
                        LoggerConfigName = Str
                    end
                end

                net.WriteString(LoggerContextName)
                net.WriteString(LoggerConfigName)
                net.SendToServer()
            end):SetIcon("icon16/cross.png")

            Menu:Open()
        end
    end, function()
        ListView:Clear()
        net.Start("Log4g_CLReq_LoggerConfigs")
        net.SendToServer()

        local function SetProperLineText(tbl, line)
            for i, j in pairs(tbl) do
                for m, n in ipairs(ListView.Columns) do
                    if i == n:GetChild(0):GetText() then
                        line:SetColumnText(m, j)
                    end
                end
            end
        end

        net.Receive("Log4g_CLRcv_LoggerConfigs", function()
            for _, v in ipairs(util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))) do
                local Line = ListView:AddLine()
                SetProperLineText(v, Line)
            end
        end)
    end)

    PanelTimedFunc(Tree, UpdateInterval, function()
        function Tree:DoRightClick(node)
            if node:GetIcon() ~= "icon16/folder.png" then return end
            local Menu = DermaMenu()

            Menu:AddOption("Remove", function()
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
        local Window = CreateDFrame(400, 300, "New LoggerConfig", "icon16/application_view_list.png")
        local DProp = vgui.Create("DProperties", Window)
        DProp:Dock(FILL)
        local RowA, RowB = DPropNewRow(DProp, "Hook", "Event Name", "Combo"), DPropNewRow(DProp, "Hook", "Unique Identifier", "Generic")
        local RowC, RowD = DPropNewRow(DProp, "Logger", "LoggerContext", "Generic"), DPropNewRow(DProp, "Logger", "Level", "Combo")
        local RowE, RowF = DPropNewRow(DProp, "Logger", "Appender", "Combo"), DPropNewRow(DProp, "Logger", "Layout", "Combo")
        local RowG = DPropNewRow(DProp, "Self", "LoggerConfig Name", "Generic")
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
            local box = row:GetChild(1):GetChild(0):GetChild(0)
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
            local InputtedName = GetRowControlValue(RowG)
            local InputtedUID = GetRowControlValue(RowB)
            local InputtedLoggerContextName = GetRowControlValue(RowC)
            if (not isstring(InputtedName)) or (not isstring(InputtedUID)) or (not isstring(InputtedLoggerContextName)) then return end
            net.Start("Log4g_CLUpload_LoggerConfig")

            net.WriteTable({
                name = string.lower(InputtedName),
                eventname = GetRowControlValue(RowA),
                uid = InputtedUID,
                loggercontext = string.lower(InputtedLoggerContextName),
                level = GetRowControlValue(RowD),
                appender = GetRowControlValue(RowE),
                layout = GetRowControlValue(RowF)
            })

            net.SendToServer()
        end
    end):SetIcon("icon16/cog_add.png")

    SubMenuB:AddOption("Level", function()
        local Window = CreateDFrame(300, 150, "New Level", "icon16/application.png")
        local DProp = vgui.Create("DProperties", Window)
        DProp:Dock(FILL)
        local RowA, RowB = DPropNewRow(DProp, "Self", "Name", "Generic"), DPropNewRow(DProp, "Self", "IntLevel", "Generic")
        local ButtonB = CreateDButton(Window, BOTTOM, 100, 0, 100, 0, 100, 50, "Submit")

        ButtonB.DoClick = function()
            net.Start("Log4g_CLUpload_NewLevel")

            net.WriteTable({
                name = GetRowControlValue(RowA),
                int = tonumber(GetRowControlValue(RowB))
            })

            net.SendToServer()
        end
    end):SetIcon("icon16/chart_bar.png")

    MenuC:AddOption("About", function()
        local Window = CreateDFrame(300, 150, "About", "icon16/information.png")
        local Text = vgui.Create("RichText", Window)
        Text:Dock(FILL)
        Text:InsertColorChange(192, 192, 192, 255)

        AppendRichTextViaTbl(Text, {
            [1] = "Log4g is an open-source addon for Garry's Mod.\n",
            [2] = "\n",
            [3] = "GitHub Page: https://github.com/GrayWolf64/Log4g\n",
            [4] = "\n",
            [5] = "Documentation can be seen on GitHub Page as well.\n"
        })
    end):SetIcon("icon16/information.png")

    local ButtonC = CreateDButton(SheetPanelB, BOTTOM, 1, 1, 840, 1, 100, 50, "Actions")

    ButtonC.Paint = function(self, w, h)
        surface.SetDrawColor(Color(255, 215, 0))
        self:DrawFilledRect()
        surface.SetDrawColor(Color(105, 105, 105))
        self:DrawOutlinedRect()
    end

    function ButtonC:DoClick()
        local Menu = DermaMenu()
        local SubA = Menu:AddSubMenu("Build LoggerConfigs (SV)")

        SubA:AddOption("Default", function()
            net.Start("Log4g_CLReq_LoggerConfig_BuildDefault")
            net.SendToServer()
        end)

        Menu:AddSpacer()
        local SubB = Menu:AddSubMenu("View")

        SubB:AddOption("Clear", function()
            ListView:Clear()
            Tree:Clear()
        end)

        SubB:AddOption("Update Frequency")
        Menu:Open()
    end

    local _ = CreateDHDivider(SheetPanelB, ListView, Tree, 4, 735, 150)
end)