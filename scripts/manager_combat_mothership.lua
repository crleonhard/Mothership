-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	--CombatManager.setCustomAddNPC(addNPC);
	CombatRecordManager.setRecordTypePostAddCallback("npc", onNPCPostAdd);
	CombatManager.setCustomCombatReset(resetInit);
	
	CombatManager2.resetInit = resetInit;
	CombatManager2.rollEntryInit = rollEntryInit;
	CombatManager2.singleNPCReset = singleNPCReset;
end

-- function addNPC(sClass, nodeNPC, sName)
	-- local nodeCT, nodeLastMatch = CombatManager.addNPCHelper(nodeNPC, sName);
	-- local sClass, sRecord = DB.getValue(nodeCT, "link");
	-- if sClass == "npc" then
		-- DB.setValue(nodeCT, "initresult", "number", 0);
	-- end

	-- return nodeCT;
-- end

function onNPCPostAdd(tCustom)

	-- if savedOldFn then
		-- savedOldFn(tCustom);
	-- end
	local nodeCT = tCustom.nodeCT;
	-- local sMCInitDice = OptionsManager.getOption("MCInitDice");
	local sClass, sRecord = DB.getValue(nodeCT, "link");
	if sClass == "npc" then
		DB.setValue(nodeCT, "initresult", "number", 0);
		local nInstinct = DB.getValue(tCustom.nodeRecord, "stats.instinct", 0);
		if nInstinct == 0 then
			nInstinct = StringManager.evalDiceString(DB.getValue(tCustom.nodeRecord, "randominstinct", ""), true, false);
			DB.setValue(nodeCT, "stats.instinct", "number", nInstinct);
		end
		local nLoyalty = DB.getValue(tCustom.nodeRecord, "loyalty", 0);
		if nLoyalty == 0 then
			nLoyalty = StringManager.evalDiceString(DB.getValue(tCustom.nodeRecord, "randomloyalty", ""), true, false);
			DB.setValue(nodeCT, "loyalty", "number", nLoyalty);
		end
	end

	return nodeCT;
end

function resetInit()
	for _,nodeCT in pairs(CombatManager.getCombatantNodes()) do
		local sClass, sRecord = DB.getValue(nodeCT, "link");
		local nNewInit = 0;
		if sClass == "charsheet" and sRecord then
			if OptionsManager.getOption	("HRSTO") == "on" then
				local nodeChar = DB.findNode(sRecord);
				local nRoll = math.random(100) - 1;
				if CharArmorManager.hasSpeedPenalty(nodeChar) then
					nRoll = math.max(nRoll, math.random(100) - 1);
				end
				local nSpeed = DB.getValue(nodeChar, "stats.speed", 0);
				if nRoll < nSpeed then
					nNewInit = 1;
				else
					nNewInit = -1;
				end
			end
			DB.setValue(nodeCT, "initresult", "number", nNewInit);
		elseif sClass == "npc" then
			DB.setValue(nodeCT, "initresult", "number", nNewInit);
		end
	end
end

function rollEntryInit(nodeEntry)
	if not nodeEntry then
		return;
	end
	local sMCRerollPC = OptionsManager.getOption("MCRerollPCInitDice");
	for _,nodeCT in pairs(CombatManager.getCombatantNodes()) do
		local sClass, sRecord = DB.getValue(nodeCT, "link");
		local nNewInit = 0;
		-- if sClass == "charsheet" and sRecord then
			-- local nodeChar = DB.findNode(sRecord);
			-- local nRoll = math.random(100) - 1;
			-- if CharArmorManager.hasSpeedPenalty(nodeChar) then
				-- nRoll = math.max(nRoll, math.random(100) - 1);
			-- end
			-- if nRoll < DB.getValue(nodeChar, "stats.speed",0) then
				-- nNewInit = 1;
			-- else
				-- nNewInit = -1;
			-- end
			-- if sMCRerollPC == "Reroll" then
				-- DB.setValue(nodeCT, "initresult", "number", nNewInit);
			-- end
			-- if sMCRerollPC == "Reset" then
				-- DB.setValue(nodeCT, "initresult", "number", 0);
			-- end
		-- elseif sClass == "npc" then
			DB.setValue(nodeCT, "initresult", "number", nNewInit);
		-- end
	end
end

function singleNPCReset()
	local sMCRerollPC = OptionsManager.getOption("MCRerollPCInitDice");
	local sClass, sRecord = DB.getValue(nodeCT, "link");
	if sClass == "npc" then
		DB.setValue(nodeCT, "initresult", "number", 0);
	end
end
