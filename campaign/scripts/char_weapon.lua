-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	local nodeWeapon = getDatabaseNode();
	local nodeChar = DB.getChild(nodeWeapon, "...");
	DB.addHandler(nodeWeapon.getNodeName(), "onChildUpdate", onDataChanged);
	DB.addHandler(DB.getPath(nodeChar, "stats.combat"), "onUpdate", onDataChanged);
	-- DB.addHandler(DB.getPath(nodeChar, "hudflag"), "onUpdate", onDataChanged);
	onDataChanged();
end

function onClose()
	local nodeWeapon = getDatabaseNode();
	local nodeChar = DB.getChild(nodeWeapon, "...");
	DB.removeHandler(nodeWeapon.getNodeName(), "onChildUpdate", onDataChanged);
	DB.removeHandler(DB.getPath(nodeChar, "stats.combat"), "onUpdate", onDataChanged);
	-- DB.removeHandler(DB.getPath(nodeChar, "hudflag"), "onUpdate", onDataChanged);
end

local m_sClass = "";
local m_sRecord = "";
function onLinkChanged()
	local node = getDatabaseNode();
	local sClass, sRecord = DB.getValue(node, "shortcut", "", "");
	if sClass ~= m_sClass or sRecord ~= m_sRecord then
		m_sClass = sClass;
		m_sRecord = sRecord;
		
		local sInvList = DB.getPath(DB.getChild(node, "..."), "inventorylist") .. ".";
		if sRecord:sub(1, #sInvList) == sInvList then
			carried.setLink(DB.findNode(DB.getPath(sRecord, "carried")));
		end
	end
end

function onDataChanged()
	onLinkChanged();
	onAttackChanged();
	onDamageChanged();
	onAmmoChanged();
end

function highlightAttack(bOnControl)
	if bOnControl then
		attackshade.setFrame("rowshade");
	else
		attackshade.setFrame(nil);
	end
end

function onAttackChanged()
	local nodeWeapon = getDatabaseNode();
	local nodeChar = nodeWeapon.getChild("...")

	local nCombat = CharWeaponManager.getAdustedCombat(nodeChar, nodeWeapon);
	local nSkillBonus = tonumber(DB.getValue(nodeWeapon, "skillbonus", "")) or 0;
	attackview.setValue(nCombat + nSkillBonus);
end

function onAttackAction(draginfo)
	local nodeWeapon = getDatabaseNode();
	local nodeChar = nodeWeapon.getChild("...")

	-- Build basic attack action record
	local rAction = CharWeaponManager.buildAttackAction(nodeChar, nodeWeapon, attackview.getValue());

	-- Decrement ammo
	CharWeaponManager.decrementAmmo(nodeChar, nodeWeapon);
	
	-- Perform action
	-- local rActor = ActorManager.getActor("pc", nodeChar);
	local rActor = ActorManager.resolveActor(nodeChar);
	ActionAttack.performRoll(draginfo, rActor, rAction);
	-- MothershipRoller.performAction(draginfo, rActor, attackview.getValue() .. " " .. DB.getValue(nodeWeapon, "name", "") .. " attack");
	
	return true;
end

function onDamageChanged()
	local nodeWeapon = getDatabaseNode();
	local sDamage = DB.getValue(nodeWeapon, "damage", "");
	damageview.setValue(sDamage);
end

function onAmmoChanged()
	local sShots = DB.getValue(getDatabaseNode(), "shots", "");
	if sShots then
		local bShots = StringManager.isNumberString(sShots);
		-- if not bShots then
			-- local nShots, _ = string.match(sShots, "(%d+)%s*%((%d+)%)");
			-- bShots = nShots;
		-- end
		label_ammo.setVisible(bShots);
		maxammo.setVisible(bShots);
		ammocounter.setVisible(bShots);
	end
end

function onDamageAction(draginfo)
	local nodeWeapon = getDatabaseNode();
	local nodeChar = nodeWeapon.getChild("...")

	-- Build basic damage action record
	-- local rAction = CharWeaponManager.buildDamageAction(nodeChar, nodeWeapon);
	local rAction = CharWeaponManager.buildDamageAction(nodeChar, nodeWeapon, damageview.getValue());
	
	-- Perform damage action
	-- local rActor = ActorManager.getActor("pc", nodeChar);
	local rActor = ActorManager.resolveActor(nodeChar);
	-- ActionDamage.performRoll(draginfo, rActor, rAction);
	-- MothershipDamageRoller.performAction(draginfo, rActor, damageview.getValue() .. " " .. DB.getValue(nodeWeapon, "name", "") .. " attack");
	ActionDamage.performRoll(draginfo, rActor, rAction);

	return true;
end
