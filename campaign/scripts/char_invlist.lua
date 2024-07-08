-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sortLocked = false;

function setSortLock(isLocked)
	sortLocked = isLocked;
end

function onInit()
	registerMenuItem(Interface.getString("list_menu_createitem"), "insert", 5);

	-- onEncumbranceChanged();

	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "*.name"), "onUpdate", onNameChanged);
	DB.addHandler(DB.getPath(node, "*.carried"), "onUpdate", onCarriedChanged);
	-- DB.addHandler(DB.getPath(node, "*.count"), "onUpdate", onEncumbranceChanged);
	DB.addHandler(DB.getPath(node, "*.armorpoints"), "onUpdate", onArmorChanged);
	DB.addHandler(DB.getPath(node, "*.damagereduction"), "onUpdate", onArmorChanged);
	-- DB.addHandler(DB.getPath(node, "*.armordamage"), "onUpdate", onArmorChanged);
	-- DB.addHandler(DB.getPath(node), "onChildDeleted", onEncumbranceChanged);
end

function onClose()
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "*.name"), "onUpdate", onNameChanged);
	DB.removeHandler(DB.getPath(node, "*.carried"), "onUpdate", onCarriedChanged);
	-- DB.removeHandler(DB.getPath(node, "*.count"), "onUpdate", onEncumbranceChanged);
	DB.removeHandler(DB.getPath(node, "*.armorpoints"), "onUpdate", onArmorChanged);
	DB.removeHandler(DB.getPath(node, "*.damagereduction"), "onUpdate", onArmorChanged);
	-- DB.removeHandler(DB.getPath(node, "*.armordamage"), "onUpdate", onArmorChanged);
	-- DB.removeHandler(DB.getPath(node), "onChildDeleted", onEncumbranceChanged);
end

function onMenuSelection(selection)
	if selection == 5 then
		addEntry(true);
	end
end

function onNameChanged(nodeField)
	local nodeChar = DB.getChild(nodeField, "....");
	if nodeChar then
		local nodeItem = DB.getChild(nodeField, "..");
		if ItemManager2.isWeapon(nodeItem) then
			local nodeWeapons = nodeChar.createChild("weaponlist");
			if nodeWeapons then
				local sItemNode = nodeItem.getNodeName();
				local sItemNode2 = "....inventorylist." .. nodeItem.getName();
				for _,v in pairs(DB.getChildren(nodeItem, "...weaponlist")) do
					local sClass, sRecord = DB.getValue(v, "shortcut", "", "");
					if sRecord == sItemNode or sRecord == sItemNode2 then
						local sName = DB.getValue(nodeItem, "name", "");
						DB.setValue(v, "name", "string", sName);
						return;
					end
				end
			end
		end
	end
end

function onCarriedChanged(nodeCarried)
	local nodeChar = DB.getChild(nodeCarried, "....");
	if nodeChar then
		local nodeItem = DB.getChild(nodeCarried, "..");
		local nodeCarriedItem = DB.getChild(nodeCarried, "..");

		local nCarried = nodeCarried.getValue();
		local sCarriedItem = StringManager.trim(ItemManager.getDisplayName(nodeCarriedItem)):lower();
		if sCarriedItem ~= "" then
			for _,vItem in pairs(DB.getChildren(nodeChar, "inventorylist")) do
				if vItem ~= nodeCarriedItem then
					local sLoc = StringManager.trim(DB.getValue(vItem, "location", "")):lower();
					if sLoc == sCarriedItem then
						DB.setValue(vItem, "carried", "number", nCarried);
					end
				end
			end
		end
		if ItemManager2.isArmor(nodeItem) then
			local _, _, nCount = CharArmorManager.calcArmorTotal(nodeChar);
			if nCarried == 2 and nCount > 1 then
				CharManagerMothership.outputUserMessage("char_message_armorcount", DB.getValue(nodeChar, "name", ""));
			end
		-- elseif ItemManager2.isHud(nodeItem) then
			-- CharWeaponManager.calcHudStatus(nodeChar);
		elseif ItemManager2.isWeapon(nodeItem) then
			if nCarried == 2 then
				--add
			else
				--remove
			end
		end
	end
	
	-- onEncumbranceChanged();
end

-- function onEncumbranceChanged()
	-- if CharManager.updateEncumbrance then
		-- CharManager.updateEncumbrance(window.getDatabaseNode());
	-- end
-- end

function onArmorChanged(nodeField)
	local nodeItem = DB.getChild(nodeField, "..");
	if (DB.getValue(nodeItem, "carried", 0) == 2) and ItemManager2.isArmor(nodeItem) then
		CharArmorManager.calcArmorTotal(DB.getChild(nodeItem, "..."));
	end
end

function onListChanged()
	update();
	updateContainers();
end

function update()
	local bEditMode = (window.inventorylist_iedit.getValue() == 1);
	window.idelete_header.setVisible(bEditMode);
	for _,w in ipairs(getWindows()) do
		w.idelete.setVisibility(bEditMode);
	end
end

function addEntry(bFocus)
	local w = createWindow();
	if w then
		if bFocus then
			w.name.setFocus();
		end
	end
	return w;
end

function onClickDown(button, x, y)
	return true;
end

function onClickRelease(button, x, y)
	if not getNextWindow(nil) then
		addEntry(true);
	end
	return true;
end

function onSortCompare(w1, w2)
	if sortLocked then
		return false;
	end
	return ItemManager.onInventorySortCompare(w1, w2);
end

function updateContainers()
	ItemManager.onInventorySortUpdate(self);
end

function onDrop(x, y, draginfo)
	return ItemManager.handleAnyDrop(window.getDatabaseNode(), draginfo);
end
