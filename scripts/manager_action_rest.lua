-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	ActionsManager.registerModHandler("rest", MothershipRoller.modRoll);
	ActionsManager.registerResultHandler("rest", onRoll);
end

function onRoll(rSource, rTarget, rRoll)
	local sSourceType, nodeSource = ActorManager.getTypeAndNode(rSource);
	local nRollUnder = tonumber(string.match(rRoll.sDesc, "vs (%d+)]"));

	ActionsManager2.decodeAdvantage(rRoll, nRollUnder, evaluateAdvantage);
	
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

	rRoll, _ = MothershipRoller.getDiceResults(rRoll, rTarget, nRollUnder);
	local sResult = getResult(rRoll.nTotal, nRollUnder);
	if nRollUnder then
		rMessage.text = rMessage.text .. " [" .. sResult:upper() .. "]";
		if string.match(sResult:lower(), "success") then
			if sSourceType == "pc" then
				local nReduction = math.floor(rRoll.nTotal / 10);
				local nStress = DB.getValue(nodeSource, "stress", 0);
				nReduction = math.min(nReduction, nStress - DB.getValue(nodeSource, "minstress", 0));
				if OptionsManager.getOption("HRSTR") == "on" then
					DB.setValue(nodeSource, "stress", "number", nStress - nReduction);
				end
				rMessage.text = rMessage.text .. " [-" .. nReduction .. " STRESS]";
			end
		elseif not ActionsManager2.getSafety(rRoll) then
			local nStress = DB.getValue(nodeSource, "stress", 0);
			if nStress < DataCommon.maxstress then
				if OptionsManager.getOption("HRSTR") == "on" then
					DB.setValue(nodeSource, "stress", "number", nStress + 1);
				end
				rMessage.text = rMessage.text .. "\n[+1 STRESS]";
			else
				rMessage.text = rMessage.text .. "\n[MAX STRESS EXCEEDED]";
			end
		end
	end
	
	Comm.deliverChatMessage(rMessage);
end

function getResult(nTotal, nRollUnder)
	local sResult;
	if nTotal < nRollUnder then 
		sResult = "Success";
	else
		sResult = "Failure";
	end
	return sResult;
end

function evaluateAdvantage(rRoll, nTotal1, nTotal2, nRollUnder, bDIS)
	local bSuccess1 = getResult(nTotal1, nRollUnder or 100):lower():match("success");
	local bSuccess2 = getResult(nTotal2, nRollUnder or 100):lower():match("success");
	local bFirst;

	if bSuccess1 and bSuccess2 then
		bFirst = (nTotal1 > nTotal2);
	elseif not (bSuccess1 or bSuccess2) then
		bFirst = (nTotal1 < nTotal2);
	else
		bFirst = bSuccess1;
	end
	
	if (bFirst and not bDIS) or (not bFirst and bDIS) then
		return nTotal1;
	else
		return nTotal2;
	end
end
