if CLIENT then
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
    end

    local function CreateDButton(parent, docktype, x, y, z, w, a, b, text)
        local dbutton = vgui.Create("DButton", parent)
        dbutton:Dock(docktype)
        dbutton:DockMargin(x, y, z, w)
        dbutton:SetSize(a, b)
        dbutton:SetText(text)

        return dbutton
    end

    --[[local function CreateDComboBox(parent, docktype, x, y, z, w)
        local dcombobox = vgui.Create("DComboBox", parent)
        dcombobox:Dock(docktype)
        dcombobox:DockMargin(x, y, z, w)

        return dcombobox
    end--]]
    --[[local function CreateDTextEntry(parent, docktype, x, y, z, w)
        local dtextentry = vgui.Create("DTextEntry", parent)
        dtextentry:Dock(docktype)
        dtextentry:DockMargin(x, y, z, w)

        return dtextentry
    end--]]
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
        local SVInfo = game.GetIPAddress()

        if SVInfo == "loopback" then
            SVInfo = "SinglePlayer"
        else
            SVInfo = "IP: " .. SVInfo
        end

        return SVInfo
    end

    concommand.Add("log4g_mmc", function()
        local FrameA = CreateDFrame(960, 640, "Log4g Monitoring & Management Console(MMC)" .. " - " .. GetGameInfo(), "icon16/application.png")
        local MenuBar = vgui.Create("DMenuBar", FrameA)
        local MenuA = MenuBar:AddMenu("New")
        local MenuB = MenuBar:AddMenu("Settings")
        MenuB:AddOption("General", function() end):SetIcon("icon16/wrench.png")
        local MenuC = MenuBar:AddMenu("Help")
        local SheetA = vgui.Create("DPropertySheet", FrameA)
        SheetA:Dock(FILL)
        SheetA:DockMargin(1, 1, 1, 1)
        SheetA:SetPadding(5)
        local SheetPanelA = vgui.Create("DPanel", SheetA)
        SheetA:AddSheet("Configuration", SheetPanelA, "icon16/cog.png")
        local SheetB = vgui.Create("DPropertySheet", SheetPanelA)
        SheetB:Dock(FILL)
        SheetB:DockMargin(1, 1, 1, 1)
        SheetB:SetPadding(5)
        local SheetPanelB = vgui.Create("DPanel", SheetB)
        SheetB:AddSheet("LoggerConfig", SheetPanelB)
        local DListViewA = CreateDListView(SheetPanelB, LEFT, 1, 1, 1, 0)
        local Tree = vgui.Create("DTree", SheetPanelB)
        Tree:Dock(RIGHT)
        Tree:DockMargin(1, 1, 1, 0)

        timer.Create("Log4g_CL_RepopulateVGUIElement", 5, 0, function()
            DListViewA:Clear()
            net.Start("Log4g_CLReq_LConfigs")
            net.SendToServer()

            net.Receive("Log4g_CLRcv_LConfigs", function()
                for k, v in ipairs(util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))) do
                    DListViewA:AddLine(unpack(table.ClearKeys(v)))
                end
            end)
        end)

        function FrameA:OnRemove()
            timer.Remove("Log4g_CL_RepopulateVGUIElement")
        end

        local SubMenuB = MenuA:AddSubMenu("Configuration")
        SubMenuB:SetDeleteSelf(false)

        SubMenuB:AddOption("LoggerConfig", function()
            local FrameB = CreateDFrame(400, 280, "New LoggerConfig", "icon16/application_view_list.png")
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
            net.Start("Log4g_CLReq_Hooks_SV")
            net.SendToServer()

            net.Receive("Log4g_CLRcv_Hooks_SV", function()
                for k, v in pairs(util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))) do
                    RowA:AddChoice(tostring(k))
                end
            end)

            local function AddChoiceViaNetTbl(start, receive, combobox)
                net.Start(start)
                net.SendToServer()

                net.Receive(receive, function()
                    for k, v in pairs(net.ReadTable()) do
                        combobox:AddChoice(v)
                    end
                end)
            end

            AddChoiceViaNetTbl("Log4g_CLReq_LogLevels_SV", "Log4g_CLRcv_LogLevels_SV", RowD)
            AddChoiceViaNetTbl("Log4g_CLReq_Appenders_SV", "Log4g_CLRcv_Appenders_SV", RowE)
            AddChoiceViaNetTbl("Log4g_CLReq_Layouts_SV", "Log4g_CLRcv_Layouts_SV", RowF)
            ButtonA = CreateDButton(FrameB, BOTTOM, 150, 3, 150, 3, 80, 40, "Submit")

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
                    net.Start("Log4g_CLUpld_LoggerConfig")
                    net.WriteTable(Tbl)
                    net.SendToServer()
                end
            end
        end):SetIcon("icon16/cog_add.png")

        MenuC:AddOption("About", function()
            local Window = CreateDFrame(300, 150, "About", "icon16/information.png")
            CreateDLabel(Window, TOP, 3, 3, 3, 3, "log4g is an open-source addon for Garry's Mod.")
        end):SetIcon("icon16/information.png")

        local Columns = {"Event Name", "Unique Identifier", "LoggerContext", "Log Level", "Appender", "Layout", "LoggerConfig Name"}

        for _, v in ipairs(Columns) do
            DListViewA:AddColumn(v)
        end

        local DGridA = vgui.Create("DGrid", SheetPanelB)
        DGridA:Dock(BOTTOM)
        DGridA:SetCols(2)
        DGridA:SetColWide(100)
        DGridA:SetRowHeight(50)
        DGridA:DockMargin(1, 1, 1, 1)
        local ButtonC = CreateDButton(DGridA, NODOCK, 0, 0, 0, 0, 100, 50, "SV BUILD LOGGERS")

        function ButtonC:DoClick()
        end

        local ButtonD = CreateDButton(DGridA, NODOCK, 0, 0, 0, 0, 100, 50, "SV CLR CONFIG")

        function ButtonD:DoClick()
        end

        for _, v in ipairs({ButtonC, ButtonD}) do
            DGridA:AddItem(v)
        end

        function DListViewA:Think()
            function DListViewA:OnRowRightClick(num)
                local Menu = DermaMenu()

                Menu:AddOption("Delete", function()
                    net.Start("Log4g_CLReq_DelLConfig")
                    net.WriteString(DListViewA:GetLine(num):GetColumnText(7))
                    net.SendToServer()
                end):SetIcon("icon16/cross.png")

                Menu:Open()
            end
        end

        local _ = CreateDHDivider(SheetPanelB, DListViewA, Tree, 4, 735, 150)
    end)
end