if SERVER then return end

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

local function CreateDLabel(parent, docktype, x, y, z, w, text)
    local dlabel = vgui.Create("DLabel", parent)
    dlabel:Dock(docktype)
    dlabel:DockMargin(x, y, z, w)
    dlabel:SetText(text)

    return dlabel
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

local function GetGameInfo()
    local info = game.GetIPAddress()

    if info == "loopback" then
        info = "SinglePlayer"
    end

    return info
end

concommand.Add("Log4g_MMC", function()
    local FrameA = CreateDFrame(960, 640, "Log4g Monitoring & Management Console(MMC)" .. " - " .. GetGameInfo(), "icon16/application.png")
    local MenuBar = vgui.Create("DMenuBar", FrameA)
    local CIcon = vgui.Create("DImageButton", MenuBar)
    CIcon:Dock(RIGHT)
    CIcon:DockMargin(4, 4, 4, 4)

    function CIcon:Think()
        if LocalPlayer():Ping() >= 300 then
            CIcon:SetImage("icon16/disconnect.png")
        else
            CIcon:SetImage("icon16/connect.png")
        end
    end

    CIcon:SetKeepAspect(true)
    CIcon:SetSize(16, 16)
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
    end

    SheetA:AddSheet("Configuration", SheetPanelA, "icon16/cog.png")
    local SheetB = vgui.Create("DPropertySheet", SheetPanelA)
    SheetB:Dock(FILL)
    SheetB:DockMargin(1, 1, 1, 1)
    SheetB:SetPadding(5)
    local SheetPanelB = vgui.Create("DPanel", SheetB)
    SheetB:AddSheet("LoggerConfig", SheetPanelB)
    local ListView = CreateDListView(SheetPanelB, LEFT, 1, 1, 1, 0)
    local Tree = vgui.Create("DTree", SheetPanelB)
    Tree:Dock(RIGHT)
    Tree:DockMargin(1, 1, 1, 0)

    function Tree:Think()
        function Tree:DoRightClick(node)
            if node:GetIcon() == "icon16/folder.png" then
                local Menu = DermaMenu()

                Menu:AddOption("Delete", function()
                    net.Start("Log4g_CLReq_RemoveLoggerContext")
                    net.WriteString(node:GetText())
                    net.SendToServer()
                end):SetIcon("icon16/cross.png")

                Menu:Open()
            end
        end
    end

    timer.Create("Log4g_CL_RepopulateVGUIElement", 5, 0, function()
        ListView:Clear()
        net.Start("Log4g_CLReq_LoggerConfigs")
        net.SendToServer()

        net.Receive("Log4g_CLRcv_LoggerConfigs", function()
            for _, v in ipairs(util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))) do
                ListView:AddLine(unpack(table.ClearKeys(v)))
            end
        end)

        Tree:Clear()
        net.Start("Log4g_CLReq_LoggerContextStructure")
        net.SendToServer()

        net.Receive("Log4g_CLRcv_LoggerContextStructure", function()
            if net.ReadBool() then
                local Tbl = util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))

                for k, v in pairs(Tbl) do
                    local Node = Tree:AddNode(k, "icon16/folder.png")
                    Node:SetExpanded(true)

                    for i, j in ipairs(v) do
                        Node:AddNode(j, "icon16/brick.png")
                    end
                end
            end
        end)
    end)

    function FrameA:OnRemove()
        timer.Remove("Log4g_CL_RepopulateVGUIElement")
    end

    local SubMenuB = MenuA:AddSubMenu("Configuration")
    SubMenuB:SetDeleteSelf(false)

    SubMenuB:AddOption("LoggerConfig", function()
        local FrameB = CreateDFrame(400, 300, "New LoggerConfig", "icon16/application_view_list.png")
        local DProperties = vgui.Create("DProperties", FrameB)
        DProperties:Dock(FILL)

        local function DPNewRow(category, name, prop)
            local row = DProperties:CreateRow(category, name)
            row:Setup(prop)

            return row
        end

        local function GetRowControlValue(row)
            local pnl = row:GetChild(1):GetChild(0):GetChild(0)
            local class = pnl:GetName()

            if class == "DTextEntry" then
                return pnl:GetValue()
            elseif class == "DComboBox" then
                return pnl:GetSelected()
            end
        end

        local RowA, RowB = DPNewRow("Hook", "Event Name", "Combo"), DPNewRow("Hook", "Unique Identifier", "Generic")
        local RowC, RowD = DPNewRow("Logger", "LoggerContext", "Generic"), DPNewRow("Logger", "Log Level", "Combo")
        local RowE, RowF = DPNewRow("Logger", "Appender", "Combo"), DPNewRow("Logger", "Layout", "Combo")
        local RowG = DPNewRow("Self", "LoggerConfig Name", "Generic")
        net.Start("Log4g_CLReq_Hooks")
        net.SendToServer()

        net.Receive("Log4g_CLRcv_Hooks", function()
            for k, _ in pairs(util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))) do
                RowA:AddChoice(tostring(k))
            end
        end)

        local function AddChoiceViaNetTbl(start, receive, combobox)
            net.Start(start)
            net.SendToServer()

            net.Receive(receive, function()
                for _, v in pairs(net.ReadTable()) do
                    combobox:AddChoice(v)
                end
            end)
        end

        AddChoiceViaNetTbl("Log4g_CLReq_Levels", "Log4g_CLRcv_Levels", RowD)
        AddChoiceViaNetTbl("Log4g_CLReq_Appenders", "Log4g_CLRcv_Appenders", RowE)
        AddChoiceViaNetTbl("Log4g_CLReq_Layouts", "Log4g_CLRcv_Layouts", RowF)
        ButtonA = CreateDButton(FrameB, BOTTOM, 300, 0, 0, 0, 100, 50, "Submit")

        ButtonA.DoClick = function()
            local Tbl = {
                [1] = GetRowControlValue(RowA),
                [2] = GetRowControlValue(RowB),
                [3] = GetRowControlValue(RowC),
                [4] = GetRowControlValue(RowD),
                [5] = GetRowControlValue(RowE),
                [6] = GetRowControlValue(RowF),
                [7] = GetRowControlValue(RowG)
            }

            if table.Count(Tbl) == 7 then
                net.Start("Log4g_CLUpload_LoggerConfig")
                net.WriteTable(Tbl)
                net.SendToServer()
            end
        end
    end):SetIcon("icon16/cog_add.png")

    MenuC:AddOption("About", function()
        local Window = CreateDFrame(300, 150, "About", "icon16/information.png")
        local _ = CreateDLabel(Window, TOP, 3, 3, 3, 3, "Log4g is an open-source addon for Garry's Mod.")
    end):SetIcon("icon16/information.png")

    for _, v in ipairs({"Event Name", "Unique Identifier", "LoggerContext", "Log Level", "Appender", "Layout", "LoggerConfig Name"}) do
        ListView:AddColumn(v)
    end

    local DGridA = vgui.Create("DGrid", SheetPanelB)
    DGridA:Dock(BOTTOM)
    DGridA:SetCols(3)
    DGridA:SetColWide(100)
    DGridA:SetRowHeight(50)
    DGridA:DockMargin(1, 1, 1, 1)
    local ButtonC = CreateDButton(DGridA, NODOCK, 0, 0, 0, 0, 100, 50, "SV BUILD LOGGERS")

    function ButtonC:DoClick()
        net.Start("Log4g_CLReq_BuildLogger")
        net.WriteBool(true)
        net.SendToServer()
    end

    local ButtonD = CreateDButton(DGridA, NODOCK, 0, 0, 0, 0, 100, 50, "Force Clear")

    function ButtonD:DoClick()
        ListView:Clear()
        Tree:Clear()
    end

    local Progress = vgui.Create("DProgress", DGridA)
    Progress:SetSize(100, 50)

    function Progress:Think()
        Progress:SetFraction((5 - timer.TimeLeft("Log4g_CL_RepopulateVGUIElement")) / 5)
    end

    for _, v in ipairs({ButtonC, ButtonD, Progress}) do
        DGridA:AddItem(v)
    end

    function ListView:Think()
        function ListView:OnRowRightClick(num)
            local Menu = DermaMenu()

            Menu:AddOption("Delete", function()
                net.Start("Log4g_CLReq_DelLoggerConfig")
                local Line = ListView:GetLine(num)
                net.WriteString(Line:GetColumnText(3))
                net.WriteString(Line:GetColumnText(7))
                net.SendToServer()
            end):SetIcon("icon16/cross.png")

            Menu:Open()
        end
    end

    local _ = CreateDHDivider(SheetPanelB, ListView, Tree, 4, 735, 150)
end)