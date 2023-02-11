local ClientGUIDerma = {}
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

function ClientGUIDerma.CreateDButton(parent, docktype, x, y, z, w, a, b, text)
	local dbutton = vgui.Create("DButton", parent)
	dbutton:Dock(docktype)
	dbutton:DockMargin(x, y, z, w)
	dbutton:SetSize(a, b)
	dbutton:SetText(text)

	return dbutton
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

--- Get a RowControl's value (edited by user) whether it's a DTextEntry or a DComboBox.
-- @param row The row in the DProp Panel
-- @return string value obtained
function ClientGUIDerma.GetRowControlValue(row)
	local pnl = GetRowControl(row)
	local cls = pnl:GetName()

	if cls == "DTextEntry" then
		return pnl:GetValue()
	elseif cls == "DComboBox" then
		return pnl:GetSelected()
	end
end

--- In a Panel's Think, run a function and run another function but timed.
-- @param panel The Panel which has a Think function to override
-- @param interval The function will run every given seconds
-- @param funca The first function
-- @param funcb The second function
function ClientGUIDerma.PanelTimedFunc(panel, interval, funca, funcb)
	local prevtime = os.time()

	function panel:Think()
		funca()
		local prestime = os.time()
		if prevtime + interval > prestime then
			return
		end
		funcb()
		prevtime = prevtime + interval
	end
end

return ClientGUIDerma
