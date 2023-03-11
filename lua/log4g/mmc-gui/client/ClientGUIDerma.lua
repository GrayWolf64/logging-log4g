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

--- Get a line's content text(s) at specific columns.
-- @param num The number of the line
-- @param listview The DListView containing the line
-- @param ... The texts of the specific column headers
-- @return tbl results
function ClientGUIDerma.GetColumnSpecialText(num, listview, ...)
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
-- @param tbl The table containing the needed text values, and its keys must be the same with the column texts
-- @param line The line to set the texts in
-- @param panel The DListView
function ClientGUIDerma.SetProperLineText(tbl, line, panel)
    if panel:GetClassName() ~= "DListView" or table.IsEmpty(panel.Columns) then return end

    for i, j in pairs(tbl) do
        for m, n in ipairs(panel.Columns) do
            if i == n:GetChild(0):GetText() then
                line:SetColumnText(m, j)
            end
        end
    end
end

return ClientGUIDerma