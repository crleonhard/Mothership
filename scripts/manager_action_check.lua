-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	ActionsManager.registerModHandler("check", MothershipRoller.modRoll);
	ActionsManager.registerModHandler("save", MothershipRoller.modRoll);
	ActionsManager.registerResultHandler("check", MothershipRoller.onRoll);
	ActionsManager.registerResultHandler("save", MothershipRoller.onRoll);
end

function performRoll(draginfo, rActor, rAction, bSecretRoll)
	local rRoll = getRoll(rActor, rAction, bSecretRoll);
	
	if User.isHost() and CombatManager.isCTHidden(ActorManager.getCTNode(rActor)) then
		rRoll.bSecret = true;
	end
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, rAction, bSecretRoll)
	local rRoll = {};
	rRoll.sType = rAction.sType;
	-- rRoll.aDice = { "d100", "d10" };
	rRoll.aDice = { "d100" };
	rRoll.nMod = rAction.modifier or 0;

	rRoll.sDesc = "[" .. rAction.sType:upper():gsub("REST", "SAVE");
	if rAction.nRollUnder then
		rRoll.sDesc = rRoll.sDesc .. " vs " .. rAction.nRollUnder;
	end
	rRoll.sDesc = rRoll.sDesc .. "] " .. rAction.label;
	
	local bADV = rAction.bADV or false;
	local bDIS = rAction.bDIS or false;
	
	if not bDIS then
		-- apply armor speed penalty
		local _, nodeActor = ActorManager.getTypeAndNode(rActor);
		bDIS = rAction.label == "Speed" and CharArmorManager.hasSpeedPenalty(nodeActor);
	end
	
	if bADV then
		rRoll.sDesc = rRoll.sDesc .. " [ADV]";
	end
	if bDIS then
		rRoll.sDesc = rRoll.sDesc .. " [DIS]";
	end

	rRoll.bSecret = bSecretRoll;
	
	return rRoll;
end
