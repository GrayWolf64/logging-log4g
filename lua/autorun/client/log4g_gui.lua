if CLIENT then
    local function CreateDFrame(a, b, title, icon)
        local dframe = vgui.Create("DFrame")
        dframe:MakePopup()
        dframe:SetSize(a, b)
        dframe:Center()
        dframe:SetScreenLock(true)
        dframe:SetTitle(title)
        dframe:SetIcon(icon)

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

    local function CreateDComboBox(parent, docktype, x, y, z, w)
        local dcombobox = vgui.Create("DComboBox", parent)
        dcombobox:Dock(docktype)
        dcombobox:DockMargin(x, y, z, w)

        return dcombobox
    end

    local function PaintDPanel(dpanel, rad, x, y, color)
        dpanel.Paint = function(self, w, h)
            draw.RoundedBox(rad, x, y, w, h, color)
        end
    end

    local function log4g_OpenWizardSimple()
        local Frame = CreateDFrame(300, 260, "Wizard Simple", "icon16/application_lightning.png")
        CreateDLabel(Frame, TOP, 3, 3, 3, 3, "The event name of the hook")
        local ComboBox_a = CreateDComboBox(Frame, TOP, 3, 0, 6, 3)

        for k, v in pairs(hook.GetTable()) do
            ComboBox_a:AddChoice(tostring(k))
        end

        CreateDLabel(Frame, TOP, 3, 3, 3, 3, "The unique identifier of the hook")
        local TextEntry_a = vgui.Create("DTextEntry", Frame)
        TextEntry_a:Dock(TOP)
        TextEntry_a:DockMargin(3, 0, 6, 3)
        CreateDLabel(Frame, TOP, 3, 3, 3, 3, "The Appender of the logger")
        local ComboBox_b = CreateDComboBox(Frame, TOP, 3, 0, 6, 3)
        ComboBox_b:AddChoice("Engine Console")
        ComboBox_b:AddChoice("log4g Console")
        local Button_a = CreateDButton(Frame, BOTTOM, 3, 3, 3, 3, 100, 50, "Confirm")

        Button_a.DoClick = function()
            local Content_a = ComboBox_a:GetSelected()
            local Content_b = TextEntry_a:GetValue()
            local Content_c = ComboBox_b:GetValue()

            if Content_a ~= nil and #Content_b ~= 0 and #Content_c ~= 0 then
                net.Start("log4g_configuration_clientsent")

                net.WriteTable({Content_a, Content_b, Content_c})

                net.SendToServer()
            else
                Button_a:SetEnabled(false)
                MsgC("[log4g] Can't add the configuration because of empty element(s).\n")
            end
        end
    end

    concommand.Add("log4g_openwindow", function(ply)
        local BaseFrame = CreateDFrame(850, 500, "log4g Window", "icon16/application.png")
        local MenuBar = vgui.Create("DMenuBar", BaseFrame)
        local M1 = MenuBar:AddMenu("Logger")
        local SubMenu = M1:AddSubMenu("New Logger")

        SubMenu:AddOption("Wizard Simple", function()
            log4g_OpenWizardSimple()
        end):SetIcon("icon16/cog_add.png")

        SubMenu:SetDeleteSelf(false)
        local M2 = MenuBar:AddMenu("Settings")
        M2:AddOption("General", function() end):SetIcon("icon16/wrench.png")
        local M3 = MenuBar:AddMenu("Help")
        M3:AddOption("About", function() end):SetIcon("icon16/information.png")
        local DListView_a = vgui.Create("DListView", BaseFrame)
        DListView_a:SetMultiSelect(false)
        DListView_a:Dock(LEFT)
        DListView_a:DockMargin(1, 3, 1, 3)
        DListView_a:AddColumn("Event Name")
        DListView_a:AddColumn("Unique ID")
        DListView_a:AddColumn("Appender")

        function DListView_a:Think()
            function DListView_a:OnRowRightClick(lineid)
                local Menu = DermaMenu()

                Menu:AddOption("Delete", function()
                    DListView_a:RemoveLine(lineid)
                end):SetIcon("icon16/cross.png")

                Menu:AddOption("Properties", function() end):SetIcon("icon16/page_edit.png")
                Menu:Open()
            end
        end

        local DGrid_a = vgui.Create("DGrid", BaseFrame)
        DGrid_a:Dock(BOTTOM)
        DGrid_a:SetCols(5)
        DGrid_a:SetColWide(100)
        DGrid_a:SetRowHeight(50)
        DGrid_a:DockMargin(1, 3, 3, 3)
        local Button_a = CreateDButton(DGrid_a, NODOCK, 0, 0, 0, 0, 100, 50, "Clear List")
        DGrid_a:AddItem(Button_a)

        Button_a.DoClick = function()
            DListView_a:Clear()
        end

        local Button_b = CreateDButton(DGrid_a, NODOCK, 0, 0, 0, 0, 100, 50, "Sync with Server")
        DGrid_a:AddItem(Button_b)

        Button_b.DoClick = function()
            net.Start("log4g_configuration_clientrequestdownload")
            net.SendToServer()

            net.Receive("log4g_configuration_clientdownload", function()
                local Bool = net.ReadBool()
                local ConfigTable = net.ReadTable()

                if Bool then
                    for k, v in ipairs(ConfigTable) do
                        DListView_a:AddLine(unpack(v))
                    end
                else
                    MsgC("[log4g] Request Sync failed: Server has no configuration file.\n")
                end
            end)
        end

        local Button_c = CreateDButton(DGrid_a, NODOCK, 0, 0, 0, 0, 100, 50, "Upload to Server")
        DGrid_a:AddItem(Button_c)

        Button_c.DoClick = function()
            for k, v in ipairs(DListView_a:GetLines()) do
                net.Start("log4g_configuration_clientupload")

                net.WriteTable({v:GetColumnText(1), v:GetColumnText(2), v:GetColumnText(3)})

                net.SendToServer()
            end
        end

        local ColorYellow = Color(255, 217, 0, 200)
        local Button_d = CreateDButton(DGrid_a, NODOCK, 0, 0, 0, 0, 100, 50, "SV BUILD LOGGERS")
        DGrid_a:AddItem(Button_d)
        PaintDPanel(Button_d, 2, 1, 0, ColorYellow)
        local Button_e = CreateDButton(DGrid_a, NODOCK, 0, 0, 0, 0, 100, 50, "SV CLR CONFIG")
        DGrid_a:AddItem(Button_e)
        PaintDPanel(Button_e, 2, 1, 0, ColorYellow)

        net.Receive("log4g_configuration_serversent", function()
            local ConfigTable = net.ReadTable()
            DListView_a:AddLine(unpack(ConfigTable))
        end)

        local Sheet = vgui.Create("DPropertySheet", BaseFrame)
        Sheet:Dock(RIGHT)
        Sheet:DockMargin(1, 3, 1, 3)
        local SheetPanel_a = vgui.Create("DPanel", Sheet)
        Sheet:AddSheet("Internal Console", SheetPanel_a, "icon16/application_xp_terminal.png")
        local Divider_a = vgui.Create("DHorizontalDivider", BaseFrame)
        Divider_a:Dock(FILL)
        Divider_a:SetLeft(DListView_a)
        Divider_a:SetRight(Sheet)
        Divider_a:SetDividerWidth(6)
        Divider_a:SetLeftMin(350)
        Divider_a:SetRightMin(350)
    end)
end