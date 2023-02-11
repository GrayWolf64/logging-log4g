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
return ClientGUIDerma
