local ClientGUIDerma = {}

surface.CreateFont("Log4gMMCConfigurationFileEditorDefault", {
    font = "Arial",
    size = 16
})

function ClientGUIDerma.CreateDFrame(a, b, title, icon, parent)
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

function ClientGUIDerma.CreateDListView(parent, docktype, x, y, z, w, ha, hb)
    local dlistview = vgui.Create("DListView", parent)
    dlistview:SetMultiSelect(false)
    dlistview:Dock(docktype)
    dlistview:DockMargin(x, y, z, w)
    dlistview:SetHeaderHeight(ha)
    dlistview:SetDataHeight(hb)

    return dlistview
end

function ClientGUIDerma.CreateDPropertySheet(parent, docktype, x, y, z, w, padding)
    local dpropertysheet = vgui.Create("DPropertySheet", parent)
    dpropertysheet:Dock(docktype)
    dpropertysheet:DockMargin(x, y, z, w)
    dpropertysheet:SetPadding(padding)

    return dpropertysheet
end

--- Create a new row in a DProp.
-- @param panel The DProp
-- @param category The category to put the row into
-- @param name The label of the row
-- @param prop The name of RowControl to add
-- @return row created row
function ClientGUIDerma.CreateDPropRow(panel, category, name, prop)
    local row = panel:CreateRow(category, name)
    row:Setup(prop)

    return row
end

--- Get a row's RowControl.
-- Because the official way to obtain a RowControl doesn't exist, we have to go this way.
-- @param row The row to get the RowControl from
-- @return row obtained row
function ClientGUIDerma.GetRowControl(row)
    return row:GetChild(1):GetChild(0):GetChild(0)
end

return ClientGUIDerma