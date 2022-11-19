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

    local function OpenWizardSimple()
        local Frame = CreateDFrame(300, 300, "Wizard Simple", "icon16/application_lightning.png")
        CreateDLabel(Frame, TOP, 3, 3, 3, 3, "The event name of the hook")
        local ComboBoxA = CreateDComboBox(Frame, TOP, 3, 0, 6, 3)

        for k, v in pairs(hook.GetTable()) do
            ComboBoxA:AddChoice(tostring(k))
        end

        CreateDLabel(Frame, TOP, 3, 3, 3, 3, "The unique identifier of the hook")
        local TextEntryA = vgui.Create("DTextEntry", Frame)
        TextEntryA:Dock(TOP)
        TextEntryA:DockMargin(3, 0, 6, 3)
        CreateDLabel(Frame, TOP, 3, 3, 3, 3, "The Appender of the logger")
        local ComboBoxB = CreateDComboBox(Frame, TOP, 3, 0, 6, 3)

        local Appenders = {"Engine Console", "log4g Console"}

        for k, v in ipairs(Appenders) do
            ComboBoxB:AddChoice(v)
        end

        CreateDLabel(Frame, TOP, 3, 3, 3, 3, "The filter of the logger")
        local ComboBoxC = CreateDComboBox(Frame, TOP, 3, 0, 6, 3)
        local ButtonA = CreateDButton(Frame, BOTTOM, 3, 3, 3, 3, 100, 50, "Confirm")

        ButtonA.DoClick = function()
            local function CheckTableElementValidity(table)
                for k, v in ipairs(table) do
                    if #v == 0 or v == nil then return false end
                end
            end

            local ConfigTbl = {ComboBoxA:GetSelected(), TextEntryA:GetValue(), ComboBoxB:GetValue(), ComboBoxC:GetValue()}

            if not CheckTableElementValidity(ConfigTbl) then
                net.Start("log4g_config_clientsent")
                net.WriteTable(ConfigTbl)
                net.SendToServer()
            else
                Derma_Message("[log4g] Can't add the config because of empty element(s).", "log4g Warning", "Cancel")
            end
        end
    end

    concommand.Add("log4g_openwindow", function()
        local Frame = CreateDFrame(850, 500, "log4g Window", "icon16/application.png")
        local MenuBar = vgui.Create("DMenuBar", Frame)
        local M1 = MenuBar:AddMenu("Logger")
        local SubMenu = M1:AddSubMenu("New Logger")

        SubMenu:AddOption("Wizard Simple", function()
            OpenWizardSimple()
        end):SetIcon("icon16/cog_add.png")

        SubMenu:SetDeleteSelf(false)
        local M2 = MenuBar:AddMenu("Settings")
        M2:AddOption("General", function() end):SetIcon("icon16/wrench.png")
        local M3 = MenuBar:AddMenu("Help")
        M3:AddOption("About", function() end):SetIcon("icon16/information.png")
        local DListViewA = vgui.Create("DListView", Frame)
        DListViewA:SetMultiSelect(false)
        DListViewA:Dock(LEFT)
        DListViewA:DockMargin(1, 3, 1, 3)

        local Columns = {"Event Name", "Unique ID", "Appender", "Filter"}

        for k, v in ipairs(Columns) do
            DListViewA:AddColumn(v)
        end

        local DGridA = vgui.Create("DGrid", Frame)
        DGridA:Dock(BOTTOM)
        DGridA:SetCols(5)
        DGridA:SetColWide(100)
        DGridA:SetRowHeight(50)
        DGridA:DockMargin(1, 3, 3, 3)
        local ButtonA = CreateDButton(DGridA, NODOCK, 0, 0, 0, 0, 100, 50, "Clear List")
        DGridA:AddItem(ButtonA)

        ButtonA.DoClick = function()
            DListViewA:Clear()
        end

        local ButtonB = CreateDButton(DGridA, NODOCK, 0, 0, 0, 0, 100, 50, "Sync with Server")
        DGridA:AddItem(ButtonB)

        ButtonB.DoClick = function()
            net.Start("log4g_config_clientrequestdownload")
            net.SendToServer()

            net.Receive("log4g_config_clientdownload", function()
                if net.ReadBool() then
                    for k, v in ipairs(net.ReadTable()) do
                        DListViewA:AddLine(unpack(v))
                    end
                else
                    Derma_Message("[log4g] Request Sync failed: Server has no config file.", "log4g Warning", "Cancel")
                end
            end)
        end

        local ButtonC = CreateDButton(DGridA, NODOCK, 0, 0, 0, 0, 100, 50, "Upload to Server")
        DGridA:AddItem(ButtonC)

        ButtonC.DoClick = function()
            local ConfigBuffer = {}

            for k, v in ipairs(DListViewA:GetLines()) do
                ConfigBuffer[k] = {}

                for i = 1, #Columns do
                    table.insert(ConfigBuffer[k], v:GetColumnText(i))
                end
            end

            if table.IsEmpty(ConfigBuffer) then
                Derma_Message("[log4g] Upload failed: List has no valid lines.", "log4g Warning", "Cancel")
            else
                print("Uploaded Configuration:")
                PrintTable(ConfigBuffer)
                net.Start("log4g_config_clientupload")
                net.WriteTable(ConfigBuffer)
                net.SendToServer()
            end
        end

        function DListViewA:Think()
            function DListViewA:OnRowRightClick(lineid)
                local Menu = DermaMenu()

                Menu:AddOption("Delete", function()
                    DListViewA:RemoveLine(lineid)
                end):SetIcon("icon16/cross.png")

                Menu:AddOption("Properties", function() end):SetIcon("icon16/page_edit.png")
                Menu:Open()
            end

            for k, v in ipairs({ButtonA, ButtonC}) do
                if #DListViewA:GetLines() ~= 0 then
                    v:SetEnabled(true)
                else
                    v:SetEnabled(false)
                end
            end
        end

        local ColorYellow = Color(255, 217, 0, 200)
        local ButtonD = CreateDButton(DGridA, NODOCK, 0, 0, 0, 0, 100, 50, "SV BUILD LOGGERS")
        DGridA:AddItem(ButtonD)
        PaintDPanel(ButtonD, 2, 1, 0, ColorYellow)
        local ButtonE = CreateDButton(DGridA, NODOCK, 0, 0, 0, 0, 100, 50, "SV CLR CONFIG")
        DGridA:AddItem(ButtonE)
        PaintDPanel(ButtonE, 2, 1, 0, ColorYellow)

        net.Receive("log4g_config_serversent", function()
            DListViewA:AddLine(unpack(net.ReadTable()))
        end)

        local Sheet = vgui.Create("DPropertySheet", Frame)
        Sheet:Dock(RIGHT)
        Sheet:DockMargin(1, 3, 1, 3)
        local SheetPanel_a = vgui.Create("DPanel", Sheet)
        Sheet:AddSheet("Internal Console", SheetPanel_a, "icon16/application_xp_terminal.png")
        local DividerM = vgui.Create("DHorizontalDivider", Frame)
        DividerM:Dock(FILL)
        DividerM:SetLeft(DListViewA)
        DividerM:SetRight(Sheet)
        DividerM:SetDividerWidth(6)
        DividerM:SetLeftMin(350)
        DividerM:SetRightMin(350)
    end)
end