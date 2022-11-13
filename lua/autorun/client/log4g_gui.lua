if CLIENT then
    local function log4g_OpenWizardSimple()
        local Frame = vgui.Create("DFrame")
        Frame:SetTitle("Wizard Simple")
        Frame:MakePopup()
        Frame:Center()
        Frame:SetSize(300, 350)
        Frame:SetScreenLock(true)
        local Text_a = vgui.Create("DLabel", Frame)
        Text_a:Dock(TOP)
        Text_a:DockMargin(3, 3, 3, 3)
        Text_a:SetText("The event name of the hook(to log)")
        local ComboBox_a = vgui.Create("DComboBox", Frame)
        ComboBox_a:Dock(TOP)
        ComboBox_a:DockMargin(3, 0, 6, 3)

        for k, v in pairs(hook.GetTable()) do
            ComboBox_a:AddChoice(tostring(k))
        end

        local Text_b = vgui.Create("DLabel", Frame)
        Text_b:Dock(TOP)
        Text_b:DockMargin(3, 3, 3, 3)
        Text_b:SetText("The unique identifier of the hook(to log)")
        local TextEntry_a = vgui.Create("DTextEntry", Frame)
        TextEntry_a:Dock(TOP)
        TextEntry_a:DockMargin(3, 0, 6, 3)
        local Text_c = vgui.Create("DLabel", Frame)
        Text_c:Dock(TOP)
        Text_c:DockMargin(3, 3, 3, 3)
        Text_c:SetText("The Appender of the logger")
        local ComboBox_b = vgui.Create("DComboBox", Frame)
        ComboBox_b:Dock(TOP)
        ComboBox_b:DockMargin(3, 0, 6, 3)
        ComboBox_b:AddChoice("Engine Console")
        ComboBox_b:AddChoice("log4g Console")
        local Text_d = vgui.Create("DLabel", Frame)
        Text_d:Dock(TOP)
        Text_d:DockMargin(3, 3, 3, 3)
        Text_d:SetText("Layout")
        local ComboBox_c = vgui.Create("DComboBox", Frame)
        ComboBox_c:Dock(TOP)
        ComboBox_c:DockMargin(3, 0, 6, 3)
        ComboBox_c:AddChoice("Rich Text")
        local Button_a = vgui.Create("DButton", Frame)
        Button_a:Dock(BOTTOM)
        Button_a:DockMargin(3, 3, 3, 3)
        Button_a:SetSize(100, 50)
        Button_a:SetText("Confirm")

        Button_a.DoClick = function()
            local Content_a = ComboBox_a:GetSelected()
            local Content_b = TextEntry_a:GetValue()
            local Content_c = ComboBox_b:GetValue()
            local Content_d = ComboBox_c:GetValue()

            if Content_a ~= nil and #Content_b ~= 0 and #Content_c ~= 0 and #Content_d ~= 0 then
                net.Start("log4g_loggerconfig_basicinfo_clientsent")

                net.WriteTable({Content_a, Content_b, Content_c, Content_d})

                net.SendToServer()
            else
                Button_a:SetEnabled(false)
                MsgC("[log4g] Can't add the loggerconfig because of empty element(s).\n")
            end
        end
    end

    concommand.Add("log4g_openwindow", function(ply)
        local BaseFrame = vgui.Create("DFrame")
        BaseFrame:SetTitle("log4g Window")
        BaseFrame:SetSize(850, 550)
        BaseFrame:Center()
        BaseFrame:MakePopup()
        BaseFrame:SetIcon("icon16/application.png")
        BaseFrame:SetScreenLock(true)
        local MenuBar = vgui.Create("DMenuBar", BaseFrame)
        local M1 = MenuBar:AddMenu("Logger")
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
        local DListViewWide = BaseFrame:GetWide() / 4 + 100
        DListView_a:SetWide(DListViewWide)
        DListView_a:DockMargin(1, 3, 1, 3)
        DListView_a:AddColumn("Event Name")
        DListView_a:AddColumn("Unique ID")
        DListView_a:AddColumn("Appender")
        DListView_a:AddColumn("Layout")

        function DListView_a:Think()
            function DListView_a:OnRowRightClick(lineid)
                local Menu = DermaMenu()

                Menu:AddOption("Delete", function()
                    DListView_a:RemoveLine(lineid)
                end):SetIcon("icon16/cross.png")

                Menu:Open()
            end
        end

        local DGrid_a = vgui.Create("DGrid", BaseFrame)
        DGrid_a:Dock(BOTTOM)
        DGrid_a:SetCols(4)
        local ColWide = 340 / 3
        DGrid_a:SetColWide(ColWide)
        DGrid_a:SetRowHeight(50)
        DGrid_a:DockMargin(1, 3, 3, 3)
        local Button_a = vgui.Create("DButton", DGrid_a)
        Button_a:SetText("Clear List")
        Button_a:SetSize(ColWide, 50)
        DGrid_a:AddItem(Button_a)

        Button_a.DoClick = function()
            DListView_a:Clear()
        end

        local Button_b = vgui.Create("DButton", DGrid_a)
        Button_b:SetText("Sync with Server")
        Button_b:SetSize(ColWide, 50)
        DGrid_a:AddItem(Button_b)

        Button_b.DoClick = function()
            net.Start("log4g_loggerconfig_basicinfo_clientrequestdownload")
            net.SendToServer()

            net.Receive("log4g_loggerconfig_basicinfo_clientdownload", function()
                local Bool = net.ReadBool()
                local Message = net.ReadTable()

                if Bool then
                    for k, v in ipairs(Message) do
                        DListView_a:AddLine(v[1], v[2], v[3], v[4])
                    end
                else
                    MsgC("[log4g] Request Sync failed: Server has no loggerconfig file.")
                end
            end)
        end

        local Button_c = vgui.Create("DButton", DGrid_a)
        Button_c:SetText("Upload to Server")
        Button_c:SetSize(ColWide, 50)
        DGrid_a:AddItem(Button_c)

        Button_c.DoClick = function()
            for k, v in ipairs(DListView_a:GetLines()) do
                net.Start("log4g_loggerconfig_basicinfo_clientupload")

                net.WriteTable({v:GetColumnText(1), v:GetColumnText(2), v:GetColumnText(3), v:GetColumnText(4)})

                net.SendToServer()
            end
        end

        net.Receive("log4g_loggerconfig_basicinfo_serversent", function()
            local Message = net.ReadTable()
            DListView_a:AddLine(Message[1], Message[2], Message[3], Message[4])
        end)

        local Sheet = vgui.Create("DPropertySheet", BaseFrame)
        Sheet:Dock(FILL)
        Sheet:Dock(RIGHT)
        local SheetWide_a = BaseFrame:GetWide() / 2
        Sheet:SetWide(SheetWide_a)
        Sheet:DockMargin(1, 3, 1, 3)
        local SheetPanel_a = vgui.Create("DPanel", Sheet)
        Sheet:AddSheet("Console", SheetPanel_a, "icon16/application_xp_terminal.png")
        local Button_d = vgui.Create("DButton", DGrid_a)
        Button_d:SetText("Server Build Logger")
        Button_d:SetSize(ColWide, 50)
        DGrid_a:AddItem(Button_d)
        local Divider = vgui.Create("DHorizontalDivider", BaseFrame)
        Divider:Dock(FILL)
        Divider:SetLeft(DListView_a)
        Divider:SetRight(Sheet)
        Divider:SetDividerWidth(6)
        Divider:SetLeftMin(340)
        Divider:SetRightMin(340)
    end)
end