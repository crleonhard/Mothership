-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sCmd = "motherdmg";

-- MoreCore v0.60 
function onInit()
	CustomDiceManager.add_roll_type(sCmd, performRoll, onRoll, true, "all", modRoll, nil, nil);

	ActionsManager.registerModHandler("msdamage", modRoll);
end

function performRoll(draginfo, rActor, sParams)
	if sParams == "?" or string.lower(sParams) == "help" then
		createHelpMessage();    
	else
		local rRoll = getRoll(sParams);
		ActionsManager.performAction(draginfo, rActor, rRoll);
	end
end

function getRoll(sParams)
	local rRoll = { };
	rRoll.sType = "msdamage";
	rRoll.aDice = {};
	rRoll.nMod = 0;

	local sDice, sDesc = string.match(sParams, "([^%s_]+)%s*(.*)");
	local aDice, nMod = StringManager.convertStringToDice(sDice);

	rRoll.aDice = aDice;
	rRoll.nMod = nMod;
	rRoll.sDesc = StringManager.trim("[DAMAGE] " .. (sDesc or "")) .. " " .. sDice;

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

	ActionsManager2.encodeDesktopMods(rRoll);
	ActionsManager2.encodeAdvantage(rRoll, bADV, bDIS);
end

function onRoll(rSource, rTarget, rRoll)
	ActionsManager2.decodeAdvantage(rRoll, nil, nil);
	
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	rRoll = getDiceResults(rRoll, rTarget);

	Comm.deliverChatMessage(rMessage);
end

function getDiceResults(rRoll, rTarget)
	local nTotal = 0;

    for k,v in ipairs(rRoll.aDice) do
		nTotal = nTotal + v.result;
	end
	
	rRoll.nTotal = nTotal + rRoll.nMod;
	
	return rRoll;
end

function createHelpMessage()  
  local rMessage = ChatManager.createBaseMessage(nil, nil);
  rMessage.text = rMessage.text .. "Usage: /"..sCmd.." <dice> <message>\n"; 
  rMessage.text = rMessage.text .. "The result, along with a message, is output to the chat window."; 
  Comm.deliverChatMessage(rMessage);
end
