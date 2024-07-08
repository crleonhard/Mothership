-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_APPLYATK = "applyatk";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYATK, handleApplyAttack);

	ActionsManager.registerModHandler("attack", MothershipRoller.modRoll);
	ActionsManager.registerResultHandler("attack", onAttack);
end

function handleApplyAttack(msgOOB)
	-- local rSource = ActorManager.getActor(msgOOB.sSourceType, msgOOB.sSourceNode);
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	-- local rTarget = ActorManager.getActor(msgOOB.sTargetType, msgOOB.sTargetNode);
	local rTarget = ActorManager.resolveActor(msgOOB.sTargetNode);
	applyAttack(rSource, rTarget, (tonumber(msgOOB.nSecret) == 1), msgOOB.sAttackType, msgOOB.sDesc, tonumber(msgOOB.nTotal) or 0, msgOOB.sResult);
end

function notifyApplyAttack(rSource, rTarget, bSecret, sAttackType, sDesc, nTotal, sResult)
	if not rTarget then
		return;
	end

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYATK;
	
	if bSecret then
		msgOOB.nSecret = 1;
	else
		msgOOB.nSecret = 0;
	end
	msgOOB.sAttackType = sAttackType;
	msgOOB.nTotal = nTotal;
	msgOOB.sDesc = sDesc;
	msgOOB.sResult = sResult;
	
	local sSourceType, sSourceNode = ActorManager.getTypeAndNodeName(rSource);
	msgOOB.sSourceType = sSourceType;
	msgOOB.sSourceNode = sSourceNode;

	local sTargetType, sTargetNode = ActorManager.getTypeAndNodeName(rTarget);
	msgOOB.sTargetType = sTargetType;
	msgOOB.sTargetNode = sTargetNode;

	Comm.deliverOOBMessage(msgOOB, "");
end

function performRoll(draginfo, rActor, rAction)
	local rRoll = getRoll(rActor, rAction);
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, rAction)
	local rRoll = {};
	rRoll.sType = "attack";
	-- rRoll.aDice = { "d100", "d10" };
	rRoll.aDice = { "d100" };
	rRoll.nMod = rAction.modifier or 0;

	rRoll.sDesc = "[ATTACK";
	if rAction.nRollUnder then
		rRoll.sDesc = rRoll.sDesc .. " vs " .. rAction.nRollUnder;
	end
	rRoll.sDesc = rRoll.sDesc .. "] " .. rAction.label;
		
	local bADV = rAction.bADV or false;
	local bDIS = rAction.bDIS or false;
	if bADV then
		rRoll.sDesc = rRoll.sDesc .. " [ADV]";
	end
	if bDIS then
		rRoll.sDesc = rRoll.sDesc .. " [DIS]";
	end

	-- rRoll.sDesc = rRoll.sDesc .. " [CRIT: " .. rAction.sCrit .. "]";
	
	return rRoll;
end

function onAttack(rSource, rTarget, rRoll)
	local nRollUnder = tonumber(string.match(rRoll.sDesc, "vs (%d+)]"));

	MothershipRoller.onRoll(rSource, rTarget, rRoll);

	local nTotal = rRoll.nTotal;
	if #rRoll.aDice == 0 then
		nTotal = rRoll.nMod;
	end

	local sResult;
	if nRollUnder then
		sResult = MothershipRoller.getResult(nTotal, nRollUnder);
	end
	
	if rTarget then
		notifyApplyAttack(rSource, rTarget, rRoll.bTower, rRoll.sType, rRoll.sDesc, nTotal, sResult);
	end

	-- inflict wound on critical success
	-- if sResult:lower() == "critical success" then
		-- local sCrit = (rRoll.sDesc:gsub('%[([%+%-])%]', '{%1}'):match('%[CRIT: ([%a%c%p%s]-)%]') or ""):gsub('{([%+%-])}', '[%1]');
		-- local rAction = buildCriticalDamageAction("Critical", sCrit, false);
		-- local rRoll = ActionDamage.getRoll(rSource, rAction);
		-- ActionDamage.onDamage(rSource, rTarget, rRoll);
	-- end	
end

function applyAttack(rSource, rTarget, bSecret, sAttackType, sDesc, nTotal, sResult)
	local msgShort = {font = "msgfont"};
	local msgLong = {font = "msgfont"};

	msgShort.text = "Attack ->";
	msgLong.text = "Attack [" .. nTotal .. "] ->";
	if rTarget then
		msgShort.text = msgShort.text .. " [at " .. ActorManager.getDisplayName(rTarget) .. "]";
		msgLong.text = msgLong.text .. " [at " .. ActorManager.getDisplayName(rTarget) .. "]";
	end
	if sResult ~= "" then
		msgLong.text = msgLong.text .. " " .. sResult;
	end
		
	ActionsManager.outputResult(bSecret, rSource, rTarget, msgLong, msgShort);
end

-- function buildCriticalDamageAction(sLabel, sCrit, bIsBleed)
	-- local rAction = {};
	-- rAction.label = sLabel;
	-- rAction.damage = "1 Wound";
	-- rAction.sCrit = sCrit;
	-- rAction.bIsBleed = bIsBleed;
	-- return rAction;
-- end
