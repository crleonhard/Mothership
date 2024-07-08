-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function isArmor(vRecord)
	local bIsArmor = false;

	local nodeItem;
	if type(vRecord) == "string" then
		nodeItem = DB.findNode(vRecord);
	elseif type(vRecord) == "databasenode" then
		nodeItem = vRecord;
	end
	if not nodeItem then
		return false, "", "";
	end
	
	local sTypeLower = StringManager.trim(DB.getValue(nodeItem, "type", "")):lower();
	if (sTypeLower == "armor") then
		bIsArmor = true;
	end
	
	return bIsArmor, sTypeLower;
end

function isWeapon(vRecord)
	local bIsWeapon = false;

	local nodeItem;
	if type(vRecord) == "string" then
		nodeItem = DB.findNode(vRecord);
	elseif type(vRecord) == "databasenode" then
		nodeItem = vRecord;
	end
	if not nodeItem then
		return false, "", "";
	end
	
	local sTypeLower = StringManager.trim(DB.getValue(nodeItem, "type", "")):lower();
	if (sTypeLower == "weapon") then
		bIsWeapon = true;
	end
	
	return bIsWeapon, sTypeLower;
end

function isLoadout(vRecord)
	local bIsLoadout = false;

	local nodeItem;
	if type(vRecord) == "string" then
		nodeItem = DB.findNode(vRecord);
	elseif type(vRecord) == "databasenode" then
		nodeItem = vRecord;
	end
	if not nodeItem then
		return false, "", "";
	end
	
	local sTypeLower = StringManager.trim(DB.getValue(nodeItem, "type", "")):lower();
	if (sTypeLower == "loadout") then
		bIsLoadout = true;
	end
	
	return bIsLoadout, sTypeLower;
end

-- function isHud(vRecord)
	-- local bIsHud = false;

	-- local nodeItem;
	-- if type(vRecord) == "string" then
		-- nodeItem = DB.findNode(vRecord);
	-- elseif type(vRecord) == "databasenode" then
		-- nodeItem = vRecord;
	-- end
	-- if not nodeItem then
		-- return false, "", "";
	-- end
	
	-- local sNameLower = StringManager.trim(DB.getValue(nodeItem, "name", "")):lower();
	-- if (sNameLower == "heads-up display" or sNameLower == "hud") then
		-- bIsHud = true;
	-- end
	
	-- return bIsHud, sNameLower;
-- end

function addItemToList2(sClass, nodeSource, nodeTarget, nodeTargetList)
	if LibraryData.isRecordDisplayClass("item", sClass) then
		-- if sClass == "reference_loadout" and DB.getChildCount(nodeSource, "subitems") > 0 then
		if DB.getChildCount(nodeSource, "subitems") > 0 and nodeTargetList.getName():match("inventorylist") then
			local bFound = false;
			for _,v in pairs(DB.getChildren(nodeSource, "subitems")) do
				local sSubClass, sSubRecord = DB.getValue(v, "link", "", "");
				local nSubCount = DB.getValue(v, "count", 1);
				local nArmorPoints = DB.getValue(v, "armorpoints", 0);
				local nUsedAmmo = DB.getValue(v, "usedammo", 0);
				local sDamage = DB.getValue(v, "damage", "");
				if LibraryData.isRecordDisplayClass("item", sSubClass) then
					local nodeNew = ItemManager.addItemToList(nodeTargetList, sSubClass, sSubRecord);
					if nodeNew then
						bFound = true;
						if nSubCount > 1 then
							DB.setValue(nodeNew, "count", "number", DB.getValue(nodeNew, "count", 1) + nSubCount - 1);
						end
						DB.setValue(nodeNew, "name", "string", DB.getValue(v, "name", DB.getValue(nodeNew, "name", "")));
						if nArmorPoints > 0 then
							DB.setValue(nodeNew, "armorpoints", "number", nArmorPoints);
						end
						if ItemManager2.isWeapon(nodeNew) then
							CharWeaponManager.setName(nodeNew, DB.getValue(nodeNew, "name", ""));
							if nUsedAmmo > 0 then
								CharWeaponManager.setUsedAmmo(nodeNew, nUsedAmmo);
							end
							if sDamage ~= "" then
								CharWeaponManager.setDamage(nodeNew, sDamage);
							end
						end
					end
				end
			end
			if bFound then
				return false;
			end
		-- elseif DB.getChildCount(nodeSource, "subitems") > 0 then
			-- local bFound = false;
			-- for _,v in pairs(DB.getChildren(nodeSource, "subitems")) do
				-- local sSubClass, sSubRecord = DB.getValue(v, "link", "", "");
				-- local nSubCount = DB.getValue(v, "count", 1);
				-- if LibraryData.isRecordDisplayClass("item", sSubClass) then
					-- local nodeNew = ItemManager.addItemToList(nodeTargetList, sSubClass, sSubRecord);
					-- if nodeNew then
						-- bFound = true;
						-- if nSubCount > 1 then
							-- DB.setValue(nodeNew, "count", "number", DB.getValue(nodeNew, "count", 1) + nSubCount - 1);
						-- end
					-- end
				-- end
			-- end
			-- if bFound then
				-- return false;
			-- end
		end
		
		DB.copyNode(nodeSource, nodeTarget);
		DB.setValue(nodeTarget, "locked", "number", 1);
		
		return true;
	end

	return false;
end

function addStringToList(sTarget, sText, nCount)
	local nodeTargetRecord = DB.findNode(sTarget);
	local nCount = nCount or 1;

	-- local sTempPath = "temp.stringasitem";
	-- DB.deleteNode(sTempPath);
	-- local nodeTemp = DB.createNode(sTempPath);
	-- DB.setValue(nodeTemp, "name", "string", sText);
	-- DB.setValue(nodeTemp, "count", "number", nCount);
	
	-- ItemManager.addItemToList(sTarget, "item", sTempPath);
	
	ItemManager.handleString(nodeTargetRecord, sText);
	
	-- DB.deleteNode(sTempPath);
end
