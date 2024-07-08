-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	ActionsManager.registerModHandler("stress", MothershipRoller.modRoll);
	ActionsManager.registerResultHandler("stress", onRoll);
end

function performRoll(draginfo, rActor)
	local rRoll = getRoll(rActor);
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor)
	local rRoll = {};
	rRoll.sType = "stress";
	rRoll.aDice = { "d20" };
	rRoll.nMod = 0;

	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor)
	rRoll.nStress = DB.getValue(nodeActor, "stress", 0);
	rRoll.sDesc = "[PANIC CHECK] Stress (" .. rRoll.nStress .. ")";
	
	return rRoll;
end

function onRoll(rSource, rTarget, rRoll)
	ActionsManager2.decodeAdvantage(rRoll, nil, nil);
	
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

	local sResult;
	rRoll, sResult = getDiceResults(rRoll, rTarget);

	rMessage.text = rMessage.text .. " [" .. sResult:upper() .. "]";
	
	local sSourceType, nodeSource = ActorManager.getTypeAndNode(rSource);
	local nStress = DB.getValue(nodeSource, "stress", 0);
	if sResult:lower() == "panic" then
		local sTable = "Panic Effect";
		local nodePanic = TableManager.findTable(sTable);
		if nodePanic then
			local aResults = TableManager.getResults(nodePanic, rRoll.nTotal, 0)
			rMessage.text = rMessage.text .. " " .. aResults[1].sText;		
			rMessage.text = rMessage.text .. applyPanicEffects(nodeSource, aResults[1].sText);
		else
			Debug.console(Interface.getString("table_error_lookupfail") .. " (" .. sTable .. ")");
		end
	end
	
	Comm.deliverChatMessage(rMessage);
end

function getDiceResults(rRoll, rTarget)
	local sResult;
	local nTotal = 0;

    for k,v in ipairs(rRoll.aDice) do
		nTotal = nTotal + v.result;
	end
	
	if nTotal > tonumber(rRoll.nStress) then
		sResult = "success";
	else
		sResult = "panic";
	end
	
	rRoll.nTotal = nTotal;
	
	return rRoll, sResult;
end

function applyPanicEffects(nodeSource, sPanicEffect)
	local sText = "";
	
	if sPanicEffect:match(". Reduce Maximum Wounds by 1.") then
		if OptionsManager.getOption("HREFF") == "on" then
			local nMaxWounds = math.max(DB.getValue(nodeSource, "maxwounds", 0) - 1, 0);
			local nWounds = math.min(DB.getValue(nodeSource, "wounds", 0), nMaxWounds);
			DB.setValue(nodeSource, "wounds", "number", nWounds);
			DB.setValue(nodeSource, "maxwounds", "number", nMaxWounds);
		end
		sText = sText .. " [-1 MAX WOUNDS]";
	end

	if sPanicEffect:match(". [Gg]ain 1 Stress.") then
		local nStress = DB.getValue(nodeSource, "stress", 0);
		if nStress < DataCommon.maxstress then
			if OptionsManager.getOption("HREFF") == "on" and OptionsManager.getOption("HRSTR") == "on" then
				DB.setValue(nodeSource, "stress", "number", nStress + 1);
			end
			sText = sText .. " [+1 STRESS]";
		else
			sText = sText .. " [MAX STRESS EXCEEDED BY 1, CONVERT TO STAT/SAVE LOSS]";
		end
	end

	if sPanicEffect:match(". Increase Minimum Stress by %d.") then
		local nIncrease = tonumber(sPanicEffect:match(". Increase Minimum Stress by (%d)."));
		local nMinStress = DB.getValue(nodeSource, "minstress", 0);
		local nCappedIncrease = math.min(DataCommon.maxstress - nMinStress, nIncrease)
		if nCappedIncrease > 0 then
			if OptionsManager.getOption("HREFF") == "on" and OptionsManager.getOption("HRSTR") == "on" then
				nMinStress = nMinStress + nCappedIncrease;
				local nStress = math.max(DB.getValue(nodeSource, "stress", 0), nMinStress);
				DB.setValue(nodeSource, "stress", "number", nStress);
				DB.setValue(nodeSource, "minstress", "number", nMinStress);
			end
			sText = sText .. " [+" .. nCappedIncrease .. " MIN STRESS]";
		end
		if nIncrease > nCappedIncrease then
			sText = sText .. " [MAX STRESS EXCEEDED BY " .. nIncrease - nCappedIncrease .. ", CONVERT TO STAT/SAVE LOSS]";
		end
	end

	if sPanicEffect:match(". Reduce Stress by 1d%d+.") then
		local nDie = sPanicEffect:match(". Reduce Stress by 1d(%d+).");
		local nStress = DB.getValue(nodeSource, "stress", 0);
		local nDecrease = math.min(math.random(nDie), nStress - DB.getValue(nodeSource, "minstress", 0));
		if OptionsManager.getOption("HREFF") == "on" and OptionsManager.getOption("HRSTR") == "on" then
			DB.setValue(nodeSource, "stress", "number", nStress - nDecrease);
		end
		sText = sText .. " [-" .. nDecrease .. " STRESS]";
	end

	local sCondition = sPanicEffect:match(". Gain a new Condition: ([%w%s%p]+)");
	if OptionsManager.getOption("HREFF") == "on" and sCondition then
		local nodeConditions = nodeSource.createChild("conditionlist");
		if not nodeConditions then
			return;
		end
		local nodeCondition = nodeConditions.createChild();
		if nodeCondition then
			DB.setValue(nodeCondition, "condition", "string", sCondition);
			sText = sText .. " [CONDITION]";
		end		
	end
	
	if sPanicEffect:match(". Roll twice on this table.") then
		for i = 1, 2
		do
			local aResults = TableManager.getResults(TableManager.findTable("Panic Effect"), math.random(20), 0)
			sText = sText .. "\n" .. aResults[1].sText .. applyPanicEffects(nodeSource, aResults[1].sText);
		end
	end
	
	return sText;
end
