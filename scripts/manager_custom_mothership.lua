-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "mother";

function onInit()
	CustomDiceManager.add_roll_type(sCmd, performRoll, onRoll, true, "all", modRoll, nil, nil);
end

function performRoll(draginfo, rActor, sParams)
	if sParams == "?" or string.lower(sParams) == "help" then
		createHelpMessage();    
	else
		local rRoll = getRoll(sParams);

		-- if User.isHost() and CombatManager.isCTHidden(ActorManager.getCTNode(rActor)) then
			-- rRoll.bSecret = true;
		-- end

		ActionsManager.performAction(draginfo, rActor, rRoll);
	end   
end

function getRoll(sParams)
	local rRoll = { };
	rRoll.sType = sCmd;
	-- rRoll.aDice = { "d100", "d10" };
	rRoll.aDice = { "d100" };
	rRoll.nMod = 0;

	local nRollUnder, sLabel = string.match(sParams, "(%d+)%s*(.*)");
	rRoll.sDesc = "[ROLL";
	if nRollUnder then
		rRoll.sDesc = rRoll.sDesc .. " vs " .. nRollUnder;
	end
	rRoll.sDesc = rRoll.sDesc .. "]";
	if sLabel then
		rRoll.sDesc = rRoll.sDesc .. sLabel;
	end
	
  return rRoll;
end

function modRoll(rSource, rTarget, rRoll)
	local bADV = false;
	local bDIS = false;
	if rRoll.sDesc:match(" %[ADV%]") then
		bADV = true;
		rRoll.sDesc = rRoll.sDesc:gsub(" %[ADV%]", "");
	end
	if rRoll.sDesc:match(" %[DIS%]") then
		bDIS = true;
		rRoll.sDesc = rRoll.sDesc:gsub(" %[DIS%]", "");
	end

	ActionsManager2.encodeSafety(rRoll);
	ActionsManager2.encodeDesktopMods(rRoll);
	ActionsManager2.encodeAdvantage(rRoll, bADV, bDIS);
end

function onRoll(rSource, rTarget, rRoll)
	local nRollUnder = tonumber(string.match(rRoll.sDesc, "vs (%d+)]"));

	ActionsManager2.decodeAdvantage(rRoll, nRollUnder, evaluateAdvantage);
	
	local sResult;
	if #rRoll.aDice > 0 then
		rRoll, sResult = getDiceResults(rRoll, rTarget, nRollUnder);
		if sResult then
			rRoll.sDesc = rRoll.sDesc .. " [" .. sResult:upper() .. "]";
		end
	end

	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	if #rRoll.aDice > 0 then
		if nRollUnder then
			if string.match(sResult:lower(), "failure") then
				local sSourceType, nodeSource = ActorManager.getTypeAndNode(rSource);
				if sSourceType == "pc" then
					if not ActionsManager2.getSafety(rRoll) then
						-- +1 stress on failed check or save
						local nStress = DB.getValue(nodeSource, "stress", 0);
						if nStress < DataCommon.maxstress then
							if OptionsManager.getOption("HRSTR") == "on" then
								DB.setValue(nodeSource, "stress", "number", nStress + 1);
							end
							rMessage.text = rMessage.text .. "\n[+1 STRESS]";
						else
							rMessage.text = rMessage.text .. "\n[MAX STRESS EXCEEDED]";
						end
						-- panic check on crit failed check or save
						if string.match(sResult:lower(), "critical failure") then
							if OptionsManager.getOption("HRPAN") == "on" then
								ActionPanic.performRoll(nil, rSource);
							end
							rMessage.text = rMessage.text .. "\n[PANIC CHECK]";
						end
					end
				end
			end
		end
	end

	Comm.deliverChatMessage(rMessage);
end

function getDiceResults(rRoll, rTarget, nRollUnder)
	local sResult;
	local nTotal = 0;

	if #rRoll.aDice == 0 then
		nTotal = rRoll.nTotal;
		table.insert(rRoll.aDice, { type = "d100", result = nTotal });
	elseif (#rRoll.aDice == 1) and (rRoll.aDice[1].type == "d100") and (rRoll.aDice[1].result == 100) then
		nTotal = 0;
		rRoll.aDice[1].result = 0;
	else
		for k,v in ipairs(rRoll.aDice) do
			nTotal = nTotal + v.result;
		end
	end
	
	if nRollUnder then
		sResult = getResult(nTotal, nRollUnder);
	end
	
	rRoll.nTotal = nTotal;
	
	return rRoll, sResult;
end

function createHelpMessage()  
	local rMessage = ChatManager.createBaseMessage(nil, nil);
	rMessage.text = rMessage.text .. "Usage: /"..sCmd.." <targetval> <message>\n"; 
	rMessage.text = rMessage.text .. "The result, along with a message, is output to the chat window."; 
	Comm.deliverChatMessage(rMessage);
end

function getResult(nTotal, nRollUnder)
	local sResult;
	if nTotal % 100 == 0 then
		sResult = "Critical Success";
	elseif nTotal == 99 then
		sResult = "Critical Failure";
	elseif nTotal > 89 then
		sResult = "Failure";
	elseif nTotal < nRollUnder then 
		if nTotal % 11 == 0 then
			sResult = "Critical Success";
		else
			sResult = "Success";
		end
	else
		if nTotal % 11 == 0 then
			sResult = "Critical Failure";
		else
			sResult = "Failure";
		end
	end
	return sResult;
end

function evaluateAdvantage(rRoll, nTotal1, nTotal2, nRollUnder, bDIS)
	local sResult1 = getResult(nTotal1, nRollUnder or 100);
	local sResult2 = getResult(nTotal2, nRollUnder or 100);
	local bFirst;
	
	if DataCommon.check_result[sResult1:lower()] == DataCommon.check_result[sResult2:lower()] then
		if rRoll.sType == "check" then
			-- for identical results, return higher value for opposed checks
			bFirst = (nTotal1 > nTotal2);
		else
			bFirst = (nTotal1 < nTotal2);
		end
	else
		bFirst = (DataCommon.check_result[sResult1:lower()] > DataCommon.check_result[sResult2:lower()]);
	end
	
	if (bFirst and not bDIS) or (not bFirst and bDIS) then
		return nTotal1;
	else
		return nTotal2;
	end
end
