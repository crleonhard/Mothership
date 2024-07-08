-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--
--	Weapon inventory management
--

function addToWeaponDB(nodeItem)
	-- Parameter validation
	if not ItemManager2.isWeapon(nodeItem) then
		return;
	end
	
	-- Get the weapon list we are going to add to
	local nodeChar = nodeItem.getChild("...");
	local nodeWeapons = nodeChar.createChild("weaponlist");
	if not nodeWeapons then
		return;
	end

	-- Set new weapons as equipped
	DB.setValue(nodeItem, "carried", "number", 2);

	-- Grab some information from the source node to populate the new weapon entries
	local sName = DB.getValue(nodeItem, "name", "");
	local sRange = DB.getValue(nodeItem, "range", "");
	local sShots = DB.getValue(nodeItem, "shots", "");
	local sDamage = DB.getValue(nodeItem, "damage", "");	
	local sCrit = DB.getValue(nodeItem, "crit", "");	
	local sSpecial = DB.getValue(nodeItem, "special", "");	
	--local nBonus = sSpecial:match("([%-%+]?%d+) Combat%.");
	--local nHudBonus = sSpecial:match("([%-%+]?%d+) Combat if wearing HUD%.");
	--local sAmmunition = DB.getValue(nodeItem, "ammunition", "");	

	-- default skill bonus
	local sSkillBonus;
	local bHTH = (sRange:lower() == "adjacent");
	local bExplosives = sCrit:match("Explosion");
	if bHTH and CharManagerMothership.hasSkill(nodeChar, "hand-to-hand combat") then
		sSkillBonus = "15";
		CharManagerMothership.outputUserMessage("char_message_weaponskill", "Hand-to-Hand Combat", sName);
	elseif not bHTH and bExplosives and CharManagerMothership.hasSkill(nodeChar, "explosives") then
		sSkillBonus = "15";
		CharManagerMothership.outputUserMessage("char_message_weaponskill", "Explosives", sName);
	elseif not bHTH and not bExplosives and CharManagerMothership.hasSkill(nodeChar, "firearms") then
		sSkillBonus = "15";
		CharManagerMothership.outputUserMessage("char_message_weaponskill", "Firearms", sName);
	elseif CharManagerMothership.hasSkill(nodeChar, "military training") then
		sSkillBonus = "10";
		CharManagerMothership.outputUserMessage("char_message_weaponskill", "Military Training", sName);
	end
	
	-- Create weapon entries
	local nodeWeapon = nodeWeapons.createChild();
	if nodeWeapon then
		DB.setValue(nodeWeapon, "shortcut", "windowreference", "item", "....inventorylist." .. nodeItem.getName());
		DB.setValue(nodeWeapon, "name", "string", sName);
		DB.setValue(nodeWeapon, "shots", "string", sShots);
		setMaxAmmo(nodeChar, nodeWeapon);
		DB.setValue(nodeWeapon, "damage", "string", sDamage);
		DB.setValue(nodeWeapon, "crit", "string", sCrit);
		-- DB.setValue(nodeWeapon, "bonus", "number", nBonus);
		-- DB.setValue(nodeWeapon, "hudbonus", "number", nHudBonus);
		if sSkillBonus then
			DB.setValue(nodeWeapon, "skillbonus", "string", sSkillBonus)
		end
	end
end

-- function createWeaponEntry(nodeChar, nodeWeapon, nodeItem)

	-- DB.setValue(nodeWeapon, "shortcut", "windowreference", "item", "....inventorylist." .. nodeItem.getName());
	-- DB.setValue(nodeWeapon, "name", "string", DB.getValue(nodeItem, "name", ""));
	-- DB.setValue(nodeWeapon, "shots", "string", DB.getValue(nodeItem, "shots", ""));
	-- setMaxAmmo(nodeChar, nodeWeapon);
	-- DB.setValue(nodeWeapon, "damage", "string", DB.getValue(nodeItem, "damage", ""));
	-- DB.setValue(nodeWeapon, "crit", "string", sCrit = DB.getValue(nodeItem, "crit", ""));
	-- if sSkillBonus then
		-- DB.setValue(nodeWeapon, "skillbonus", "string", sSkillBonus)
	-- end
-- end

function removeFromWeaponDB(nodeItem)
	if not nodeItem then
		return false;
	end
	
	-- Check to see if any of the weapon nodes linked to this item node should be deleted
	local sItemNode = nodeItem.getNodeName();
	local sItemNode2 = "....inventorylist." .. nodeItem.getName();
	local bFound = false;
	for _,v in pairs(DB.getChildren(nodeItem, "...weaponlist")) do
		local sClass, sRecord = DB.getValue(v, "shortcut", "", "");
		if sRecord == sItemNode or sRecord == sItemNode2 then
			bFound = true;
			v.delete();
		end
	end

	return bFound;
end

--
--	Property helpers
--

function getAdustedCombat(nodeChar, nodeWeapon)
	local nCombat = DB.getValue(nodeChar, "stats.combat", 0) + DB.getValue(nodeWeapon, "bonus", 0);
	-- local nHudFlag = DB.getValue(nodeChar, "hudflag", 0);
	-- local nHudBonus = DB.getValue(nodeWeapon, "hudbonus", 0);
	-- if nHudFlag > 0 and nHudBonus > 0 then
		-- check if char has hud equipped
		-- for _,v in pairs(DB.getChildren(nodeItem, "..")) do
			-- local sName = DB.getValue(v, "name", ""):lower();
			-- if (sName == "heads-up display" or sName == "hud") and DB.getValue(v, "carried", 0) == 2 then
				-- nCombat = nCombat + nHudBonus;
				-- break;
			-- end
		-- end
	-- end

	-- local nMod = DB.getValue(nodeWeapon, "attackbonus", 0);
	-- nMod = nMod + ActorManager2.getAbilityBonus(nodeChar, sAbility);
	-- if DB.getValue(nodeWeapon, "prof", 0) == 1 then
		-- nMod = nMod + DB.getValue(nodeChar, "profbonus", 0);
	-- end

	-- return nMod, sAbility;
	return nCombat, "";
end

function setName(nodeItem, sName)
	if not nodeItem then
		return false;
	end

	local sItemNode = nodeItem.getNodeName();
	local sItemNode2 = "....inventorylist." .. nodeItem.getName();
	for _,v in pairs(DB.getChildren(nodeItem, "...weaponlist")) do
		local sClass, sRecord = DB.getValue(v, "shortcut", "", "");
		if sRecord == sItemNode or sRecord == sItemNode2 then
			DB.setValue(v, "name", "string", sName);
		end
	end
end

function setUsedAmmo(nodeItem, nUsedAmmo)
	if not nodeItem then
		return false;
	end

	local sItemNode = nodeItem.getNodeName();
	local sItemNode2 = "....inventorylist." .. nodeItem.getName();
	for _,v in pairs(DB.getChildren(nodeItem, "...weaponlist")) do
		local sClass, sRecord = DB.getValue(v, "shortcut", "", "");
		if sRecord == sItemNode or sRecord == sItemNode2 then
			DB.setValue(v, "ammo", "number", math.min(math.max(nUsedAmmo, 0), DB.getValue(v, "maxammo", 0)));
		end
	end
end

function setDamage(nodeItem, sDamage)
	if not nodeItem then
		return false;
	end
	
	DB.setValue(nodeItem, "damage", "string", sDamage);
	
	local sItemNode = nodeItem.getNodeName();
	local sItemNode2 = "....inventorylist." .. nodeItem.getName();
	for _,v in pairs(DB.getChildren(nodeItem, "...weaponlist")) do
		local sClass, sRecord = DB.getValue(v, "shortcut", "", "");
		if sRecord == sItemNode or sRecord == sItemNode2 then
			DB.setValue(v, "damage", "string", sDamage);
		end
	end
end

--
--	Action helpers
--

function buildAttackAction(nodeChar, nodeWeapon, nRollUnder)
	local rAction = {};
	-- rAction.bWeapon = true;
	rAction.label = DB.getValue(nodeWeapon, "name", "");
	rAction.nRollUnder = nRollUnder;
	rAction.sCrit = DB.getValue(nodeWeapon, "crit", "");
	return rAction;
end

function setMaxAmmo(nodeChar, nodeWeapon)
	local sShots = DB.getValue(nodeWeapon, "shots", "");
	local bShots = StringManager.isNumberString(sShots);
	local nShots = 0;
	if bShots then
		nShots = tonumber(sShots);
	-- else
		-- nShots, nShotsTrained = string.match(sShots, "(%d+)%s*%((%d+)%)");
		-- if nShotsTrained and (CharManagerMothership.hasSkill(nodeChar, "firearms") or CharManagerMothership.hasSkill(nodeChar, "military training")) then
			-- nShots = nShotsTrained;
		-- end
	end

	DB.setValue(nodeWeapon, "maxammo", "number", nShots);
end

function decrementAmmo(nodeChar, nodeWeapon)
	local nMaxAmmo = DB.getValue(nodeWeapon, "maxammo", 0);
	if nMaxAmmo > 0 then
		local nUsedAmmo = DB.getValue(nodeWeapon, "ammo", 0);
		if nUsedAmmo >= nMaxAmmo then
			-- local rActor = ActorManager.getActor("pc", nodeChar);
			local rActor = ActorManager.resolveActor(nodeChar);
			ChatManager.Message(Interface.getString("char_message_atkwithnoammo"), true, rActor);
		else
			DB.setValue(nodeWeapon, "ammo", "number", nUsedAmmo + 1);
		end
	end
end

function buildDamageAction(nodeChar, nodeWeapon, sDamage)
	local rAction = {};
	rAction.label = DB.getValue(nodeWeapon, "name", "");
	rAction.damage = sDamage;
	rAction.sCrit = DB.getValue(nodeWeapon, "crit", "");
	rAction.bIsBleed = false;
	return rAction;
end

-- function buildDamageString(nodeChar, nodeWeapon)
	-- local aDamage = {};
	-- local clauses = getDamageClauses(nodeChar, nodeWeapon);
	-- for _,v in ipairs(clauses) do
		-- if (#(v.dice) > 0) or (v.modifier ~= 0) then
			-- local sDamage = StringManager.convertDiceToString(v.dice, v.modifier);
			-- table.insert(aDamage, sDamage);
		-- end
	-- end
	-- return table.concat(aDamage, "\n");
-- end

-- function calcHudStatus(nodeChar)
	-- local nHudFlag = 0;
	-- for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
		-- if DB.getValue(vNode, "carried", 0) == 2 then
			-- local bIsHud, _ = ItemManager2.isHud(vNode);
			-- if bIsHud then
				-- nHudFlag = 1;
				-- break;
			-- end
		-- end
	-- end
	-- DB.setValue(nodeChar, "hudflag", "number", nHudFlag);
-- end