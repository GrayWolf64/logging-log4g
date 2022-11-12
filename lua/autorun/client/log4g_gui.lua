if CLIENT then
    local function log4g_OpenWizardSimple()
        local Frame = vgui.Create("DFrame")
        Frame:SetTitle("Wizard Simple")
        Frame:MakePopup()
        Frame:Center()
        Frame:SetSize(300, 200)
        Frame:SetScreenLock(true)
        local Text_a = vgui.Create("DLabel", Frame)
        Text_a:Dock(TOP)
        Text_a:DockMargin(3, 3, 3, 3)
        Text_a:SetText("The event name of the hook.")
        local ComboBox_a = vgui.Create("DComboBox", Frame)
        ComboBox_a:Dock(TOP)
        ComboBox_a:DockMargin(3, 0, 3, 3)

        for k, v in pairs(hook.GetTable()) do
            ComboBox_a:AddChoice(tostring(k))
        end

        local Text_b = vgui.Create("DLabel", Frame)
        Text_b:Dock(TOP)
        Text_b:DockMargin(3, 3, 3, 3)
        Text_b:SetText("The unique identifier of the hook.")
        local TextEntry_a = vgui.Create("DTextEntry", Frame)
        TextEntry_a:Dock(TOP)
        TextEntry_a:DockMargin(3, 0, 6, 3)
        local Button_a = vgui.Create("DButton", Frame)
        Button_a:Dock(BOTTOM)
        Button_a:DockMargin(3, 3, 3, 3)
        Button_a:SetSize(100, 50)
        Button_a:SetText("Confirm")

        Button_a.DoClick = function()
            local Text = TextEntry_a:GetValue()

            if #Text ~= 0 then
                net.Start("log4g_loggerconfig_eventname_clientsent")
                net.WriteString(ComboBox_a:GetSelected())
                net.SendToServer()
                net.Start("log4g_loggerconfig_uniqueidentifier_clientsent")
                net.WriteString(Text)
                net.SendToServer()
            else
                Button_a:SetEnabled(false)
                MsgC("[log4g] Can't request an empty ID.\n")
            end
        end
    end

    concommand.Add("log4g_openwindow", function(ply)
        local BaseFrame = vgui.Create("DFrame")
        BaseFrame:SetTitle("log4g Window")
        BaseFrame:SetSize(800, 400)
        BaseFrame:Center()
        BaseFrame:MakePopup()
        BaseFrame:SetIcon("icon16/application.png")
        BaseFrame:SetScreenLock(true)
        local MenuBar = vgui.Create("DMenuBar", BaseFrame)
        local M1 = MenuBar:AddMenu("Logger Config")
        local Sub = M1:AddSubMenu("New Logger")

        Sub:AddOption("Wizard Simple", function()
            log4g_OpenWizardSimple()
        end):SetIcon("icon16/cog_add.png")

        Sub:SetDeleteSelf(false)
        local M2 = MenuBar:AddMenu("Settings")
        M2:AddOption("Modify", function() end):SetIcon("icon16/wrench.png")
        local M3 = MenuBar:AddMenu("Help")
        M3:AddOption("About", function() end):SetIcon("icon16/information.png")
        local DListView_a = vgui.Create("DListView", BaseFrame)
        DListView_a:SetMultiSelect(false)
        DListView_a:Dock(LEFT)
        local DListViewWide = BaseFrame:GetWide() / 4 + 120
        DListView_a:SetWide(DListViewWide)
        DListView_a:DockMargin(1, 3, 1, 1)
        DListView_a:AddColumn("Event Name")
        DListView_a:AddColumn("Unique Identifier")

        function DListView_a:Think()
            function DListView_a:OnRowRightClick(lineid)
                local Menu = DermaMenu()

                Menu:AddOption("Delete", function()
                    DListView_a:RemoveLine(lineid)
                end):SetIcon("icon16/cross.png")

                Menu:Open()
            end
        end

        net.Receive("log4g_loggerconfig_eventname_serversent", function()
            local Col1 = net.ReadString()

            net.Receive("log4g_loggerconfig_uniqueidentifier_serversent", function()
                local Col2 = net.ReadString()
                DListView_a:AddLine(Col1, Col2)
            end)
        end)

        local Sheet = vgui.Create("DPropertySheet", BaseFrame)
        Sheet:Dock(FILL)
        Sheet:Dock(RIGHT)
        local SheetWide_a = BaseFrame:GetWide() / 2 + 70
        Sheet:SetWide(SheetWide_a)
        Sheet:DockMargin(1, 3, 1, 1)
        local SheetPanel_a = vgui.Create("DPanel", Sheet)
        Sheet:AddSheet("Console", SheetPanel_a, "icon16/application_xp_terminal.png")
        local Divider = vgui.Create("DHorizontalDivider", BaseFrame)
        Divider:Dock(FILL)
        Divider:SetLeft(DListView_a)
        Divider:SetRight(Sheet)
        Divider:SetDividerWidth(6)
        Divider:SetLeftMin(240)
        Divider:SetRightMin(240)
    end)
end