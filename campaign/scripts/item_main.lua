
function onDrop(x, y, draginfo)
	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		local bLoadout = ItemManager2.isLoadout(sRecord);
		if bLoadout then
			Debug.console(Interface.getString("item_error_recursion"));
			return false;
		end
	end
	super.onDrop(x, y, draginfo);
end

function update()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);

	local bWeapon = ItemManager2.isWeapon(nodeRecord);
	local bArmor = ItemManager2.isArmor(nodeRecord);
	local bLoadout = ItemManager2.isLoadout(nodeRecord);
	
	-- local bSection2 = false;
	-- if WindowManager.callSafeControlUpdate(self, "type", bReadOnly) then bSection2 = true; end
	local bSection2 = true;
	type.setReadOnly(bReadOnly);	

	local bSection3 = false;
	if WindowManager.callSafeControlUpdate(self, "cost", bReadOnly, bLoadout) then bSection3 = true; end
	
	local bSection4 = false;
	if WindowManager.callSafeControlUpdate(self, "damage", bReadOnly or not bWeapon) then bSection4 = true; end
	if WindowManager.callSafeControlUpdate(self, "crit", bReadOnly or not bWeapon) then bSection4 = true; end
	if WindowManager.callSafeControlUpdate(self, "range", bReadOnly or not bWeapon) then bSection4 = true; end
	-- if WindowManager.callSafeControlUpdate(self, "ammunition", bReadOnly or not bWeapon) then bSection4 = true; end
	if WindowManager.callSafeControlUpdate(self, "shots", bReadOnly or not bWeapon) then bSection4 = true; end
	-- if WindowManager.callSafeControlUpdate(self, "usedammo", bReadOnly or not bWeapon) then bSection4 = true; end
	if WindowManager.callSafeControlUpdate(self, "special", bReadOnly or not (bWeapon or bArmor)) then bSection4 = true; end
	
	if WindowManager.callSafeControlUpdate(self, "armorpoints", bReadOnly or not bArmor) then bSection4 = true; end
	-- if WindowManager.callSafeControlUpdate(self, "armordamage", bReadOnly or not bArmor) then bSection4 = true; end
	if WindowManager.callSafeControlUpdate(self, "damagereduction", bReadOnly or not bArmor) then bSection4 = true; end
	if WindowManager.callSafeControlUpdate(self, "o2supply", bReadOnly or not bArmor) then bSection4 = true; end
	if WindowManager.callSafeControlUpdate(self, "speed", bReadOnly or not bArmor) then bSection4 = true; end
	
	local bSection5 = false;
	if WindowManager.callSafeControlUpdate(self, "description", bReadOnly, bWeapon) then bSection5 = true; end
	if WindowManager.callSafeControlUpdate(self, "notes", bReadOnly) then bSection5 = true; end

	if bLoadout then
		sub_subitems.setValue("item_main_subitems", nodeRecord);
	else
		sub_subitems.setValue("", "");
	end
	sub_subitems.update(bReadOnly);
	
	divider.setVisible(bSection2 and bSection3);
	divider2.setVisible((bSection2 or bSection3 or bSection4) and bSection5);
end
