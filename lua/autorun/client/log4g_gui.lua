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

    local function CreateDComboBox(parent, docktype, x, y, z, w)
        local dcombobox = vgui.Create("DComboBox", parent)
        dcombobox:Dock(docktype)
        dcombobox:DockMargin(x, y, z, w)

        return dcombobox
    end

    local function CheckTblElementValidity(tbl)
        for _, v in ipairs(tbl) do
            if v == nil then return true end
        end

        return false
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
        local FrameA = CreateDFrame(850, 500, "log4g Monitoring & Management Console(MMC)" .. " - " .. GetGameInfo(), "icon16/application.png")
        local MenuBar = vgui.Create("DMenuBar", FrameA)
        local MenuA = MenuBar:AddMenu("Logger")
        local SubMenuA = MenuA:AddSubMenu("New LoggerConfig")
        SubMenuA:SetDeleteSelf(false)
        local MenuB = MenuBar:AddMenu("Settings")
        MenuB:AddOption("General", function() end):SetIcon("icon16/wrench.png")
        local MenuC = MenuBar:AddMenu("Help")
        local Sheet = vgui.Create("DPropertySheet", FrameA)
        Sheet:Dock(FILL)
        Sheet:DockMargin(1, 1, 1, 1)
        local SheetPanelA = vgui.Create("DPanel", Sheet)
        Sheet:AddSheet("Configuration", SheetPanelA, "icon16/cog_edit.png")
        local DListViewA = vgui.Create("DListView", SheetPanelA)
        DListViewA:SetMultiSelect(false)
        DListViewA:Dock(LEFT)
        DListViewA:DockMargin(1, 1, 1, 0)
        local Tree = vgui.Create("DTree", SheetPanelA)
        Tree:Dock(RIGHT)
        Tree:DockMargin(1, 1, 1, 0)

        SubMenuA:AddOption("Wizard Simple", function()
            local FrameB = CreateDFrame(300, 360, "Wizard Simple", "icon16/application_lightning.png")
            CreateDLabel(FrameB, TOP, 3, 3, 3, 3, "The event name of the hook(Serverside)")
            local ComboBoxA = CreateDComboBox(FrameB, TOP, 3, 0, 6, 3)
            net.Start("log4g_hooks_clientrequest")
            net.SendToServer()

            net.Receive("log4g_hooks_clientdownload", function()
                for k, v in pairs(util.JSONToTable(util.Decompress(net.ReadData(net.ReadUInt(16))))) do
                    ComboBoxA:AddChoice(tostring(k))
                end
            end)

            CreateDLabel(FrameB, TOP, 3, 3, 3, 3, "The unique identifier of the hook")
            local TextEntryA = vgui.Create("DTextEntry", FrameB)
            TextEntryA:Dock(TOP)
            TextEntryA:DockMargin(3, 0, 6, 3)
            CreateDLabel(FrameB, TOP, 3, 3, 3, 3, "The appender of the logger")
            local ComboBoxB = CreateDComboBox(FrameB, TOP, 3, 0, 6, 3)

            local Appenders = {"Engine Console", "log4g Terminal"}

            for _, v in ipairs(Appenders) do
                ComboBoxB:AddChoice(v)
            end

            CreateDLabel(FrameB, TOP, 3, 3, 3, 3, "The filter of the logger")
            local ComboBoxC = CreateDComboBox(FrameB, TOP, 3, 0, 6, 3)
            local ButtonA = CreateDButton(FrameB, BOTTOM, 60, 3, 60, 3, 100, 50, "Confirm")

            local Filters = {"BurstFilter"}

            for _, v in ipairs(Filters) do
                ComboBoxC:AddChoice(v)
            end

            CreateDLabel(FrameB, TOP, 3, 3, 3, 3, "The parent of the LoggerConfig")
            local ComboBoxD = CreateDComboBox(FrameB, TOP, 3, 0, 6, 3)

            local Parent = {"None"}

            for _, v in ipairs(Parent) do
                ComboBoxD:AddChoice(v)
            end

            ButtonA.DoClick = function()
                local ConfigTbl = {ComboBoxA:GetSelected(), TextEntryA:GetValue(), ComboBoxB:GetSelected(), ComboBoxC:GetSelected(), ComboBoxD:GetSelected()}

                if not CheckTblElementValidity(ConfigTbl) then
                    DListViewA:AddLine(unpack(ConfigTbl))
                else
                    Derma_Message("Can't add the LoggerConfig because of empty element(s).", "log4g Warning", "Cancel")
                end
            end
        end):SetIcon("icon16/cog_add.png")

        MenuC:AddOption("About", function()
            local FrameC = CreateDFrame(300, 200, "About", "icon16/information.png")
            CreateDLabel(FrameC, TOP, 3, 3, 3, 3, "log4g is an open-source addon for Garry's Mod.")
        end):SetIcon("icon16/information.png")

        local Columns = {"Event Name", "Unique ID", "Appender", "Filter", "Parent"}

        for _, v in ipairs(Columns) do
            DListViewA:AddColumn(v)
        end

        local DGridA = vgui.Create("DGrid", SheetPanelA)
        DGridA:Dock(BOTTOM)
        DGridA:SetCols(5)
        DGridA:SetColWide(100)
        DGridA:SetRowHeight(50)
        DGridA:DockMargin(1, 1, 1, 1)
        local ButtonA = CreateDButton(DGridA, NODOCK, 0, 0, 0, 0, 100, 50, "Clear List")

        ButtonA.DoClick = function()
            DListViewA:Clear()
        end

        local ButtonB = CreateDButton(DGridA, NODOCK, 0, 0, 0, 0, 100, 50, "Sync with Server")

        ButtonB.DoClick = function()
            net.Start("log4g_config_clientrequest_download")
            net.SendToServer()

            net.Receive("log4g_config_clientdownload", function()
                if net.ReadBool() then
                    for _, v in ipairs(net.ReadTable()) do
                        DListViewA:AddLine(unpack(v))
                    end
                else
                    Derma_Message("Request Sync failed: Server has no config file.", "log4g Warning", "Cancel")
                end
            end)
        end

        local ButtonC = CreateDButton(DGridA, NODOCK, 0, 0, 0, 0, 100, 50, "Upload to Server")

        ButtonC.DoClick = function()
            local ConfigBuffer = {}

            for k, v in ipairs(DListViewA:GetLines()) do
                ConfigBuffer[k] = {}

                for i = 1, #Columns do
                    table.insert(ConfigBuffer[k], v:GetColumnText(i))
                end
            end

            if table.IsEmpty(ConfigBuffer) then
                Derma_Message("Upload failed: List has no valid lines.", "log4g Warning", "Cancel")
            else
                print("[log4g] Client Uploaded Configuration:")
                PrintTable(ConfigBuffer)
                net.Start("log4g_config_clientupload")
                net.WriteTable(ConfigBuffer)
                net.SendToServer()
            end
        end

        local ButtonD = CreateDButton(DGridA, NODOCK, 0, 0, 0, 0, 100, 50, "SV BUILD LOGGERS")

        function ButtonD:DoClick()
            net.Start("log4g_config_clientrequest_buildlogger")
            net.SendToServer()
        end

        local ButtonE = CreateDButton(DGridA, NODOCK, 0, 0, 0, 0, 100, 50, "SV CLR CONFIG")

        function ButtonE:DoClick()
            net.Start("log4g_config_clientrequest_clrconfig")
            net.SendToServer()
        end

        for _, v in ipairs({ButtonA, ButtonB, ButtonC, ButtonD, ButtonE}) do
            DGridA:AddItem(v)
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

            for _, v in ipairs({ButtonA, ButtonC}) do
                if #DListViewA:GetLines() ~= 0 then
                    v:SetEnabled(true)
                else
                    v:SetEnabled(false)
                end
            end
        end

        local DividerM = vgui.Create("DHorizontalDivider", SheetPanelA)
        DividerM:Dock(FILL)
        DividerM:SetLeft(DListViewA)
        DividerM:SetRight(Tree)
        DividerM:SetDividerWidth(4)
        DividerM:SetLeftMin(500)
        DividerM:SetRightMin(200)
    end)
end