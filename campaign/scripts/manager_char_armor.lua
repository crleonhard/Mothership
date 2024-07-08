-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function addToArmorDB(nodeItem)
	-- Parameter validation
	local bIsArmor, _, sSubtypeLower = ItemManager2.isArmor(nodeItem);
	if not bIsArmor then
		return;
	end
	
	-- Determine whether to auto-equip armor
	-- local nodeChar = nodeItem.getChild("...");
	local bArmorEquipped = false;
	for _,v in pairs(DB.getChildren(nodeItem, "..")) do
		if DB.getValue(v, "carried", 0) == 2 then
			local bIsItemArmor, _, sItemSubtypeLower = ItemManager2.isArmor(v);
			if bIsItemArmor then
				bArmorEquipped = true;
			end
		end
	end
	if not bArmorEquipped then
		DB.setValue(nodeItem, "carried", "number", 2);
	end
end

function removeFromArmorDB(nodeItem)
	-- Parameter validation
	if not ItemManager2.isArmor(nodeItem) then
		return;
	end
	
	-- If this armor was worn, recalculate armor save
	if DB.getValue(nodeItem, "carried", 0) == 2 then
		DB.setValue(nodeItem, "carried", "number", 1);
	end
end

function calcArmorTotal(nodeChar)
	local nArmorTotal, nDamageReductionTotal, nArmorCount = 0, 0, 0;
	for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
		if DB.getValue(vNode, "carried", 0) == 2 then
			local bIsArmor, _ = ItemManager2.isArmor(vNode);
			if bIsArmor then
				nArmorTotal = nArmorTotal + DB.getValue(vNode, "armorpoints", 0);
				nDamageReductionTotal = nDamageReductionTotal + DB.getValue(vNode, "damagereduction", 0);
				nArmorCount = nArmorCount + 1;
			end
		end
	end
	DB.setValue(nodeChar, "armorpoints", "number", nArmorTotal);
	DB.setValue(nodeChar, "damagereduction", "number", nDamageReductionTotal);
	return nArmorTotal, nDamageReductionTotal, nArmorCount;
end

function hasSpeedPenalty(nodeChar)
	local bSpeedPenalty = false;
	for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
		if DB.getValue(vNode, "carried", 0) == 2 then
			local bIsArmor, _ = ItemManager2.isArmor(vNode);
			if bIsArmor then
				bSpeedPenalty = DB.getValue(vNode, "speed", "") == "[-]";
				if bSpeedPenalty then
					break;
				end
			end
		end
	end
	return bSpeedPenalty;
end

-- function getSpeedModifier(nodeChar)
	-- local nSpeedModifier = 0;
	-- for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
		-- if DB.getValue(vNode, "carried", 0) == 2 then
			-- local bIsArmor, _ = ItemManager2.isArmor(vNode);
			-- if bIsArmor then
				-- local nModifier = tonumber(string.match(DB.getValue(vNode, "speed", ""), "[%+%-]?(%d+)]"));
				-- Debug.console("nModifier", nModifier)
				-- if nSpeedModifier then
					-- nSpeedModifier = nSpeedModifier + nModifier;
				-- end
			-- end
		-- end
	-- end
	-- return nSpeedModifier;
-- end

function destroyArmor(nodeChar)
	for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
		if DB.getValue(vNode, "carried", 0) == 2 then
			local bIsArmor, _ = ItemManager2.isArmor(vNode);
			if bIsArmor then
				--local nArmorPoints = DB.getValue(vNode, "armorpoints", 0);
				--if nArmorPoints > 0 then
					DB.setValue(vNode, "carried", "number", 0);
					--DB.setValue(vNode, "armordamage", "number", nArmorPoints);
					local sName = DB.getValue(vNode, "name", "");
					if not string.match(sName, "%[DESTROYED%]") then
						DB.setValue(vNode, "name", "string", sName .. " [DESTROYED]")
					end
				--end
			end
		end
	end	
end

-- function getIgnoreFirstWound(nodeChar)
	-- local bIgnoreFirstWound = false;
	-- local vArmor;
	-- for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
		-- if DB.getValue(vNode, "carried", 0) == 2 then
			-- local bIsArmor, _ = ItemManager2.isArmor(vNode);
			-- if bIsArmor then
				-- bIgnoreFirstWound = DB.getValue(vNode, "special", ""):match("%. ([Ii]gnores first [Ww]ound%.)")
				-- bIgnoreFirstWound = bIgnoreFirstWound and (DB.getValue(vNode, "armordamage", 0) < DB.getValue(vNode, "armorpoints", 0));
				-- if bIgnoreFirstWound then
					-- vArmor = vNode;
					-- break;
				-- end
			-- end
		-- end
	-- end
	-- return bIgnoreFirstWound, vArmor;
-- end

-- function disableIgnoreFirstWound(vArmor)
	-- local sSpecial = DB.getValue(vArmor, "special", "");
	-- local bMatch = sSpecial:match("%. ([Ii]gnores first [Ww]ound%.)");
	-- if bMatch then
		-- -- disable "Ignores first Wound" effect by adding brackets around text
		-- DB.setValue(vArmor, "special", "string", sSpecial:gsub(bMatch, "[" .. bMatch .. "]"));
		-- local sName = DB.getValue(vArmor, "name", "");
		-- if not string.match(sName, "%[DAMAGED%]") then
			-- DB.setValue(vArmor, "name", "string", sName .. " [DAMAGED]")
		-- end
	-- end
-- end
