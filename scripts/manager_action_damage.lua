-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_APPLYDMG = "applydmg";
OOB_MSGTYPE_APPLYDMGSTATE = "applydmgstate";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYDMG, handleApplyDamage);
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYDMGSTATE, handleApplyDamageState);

	-- ActionsManager.registerModHandler("damage", MothershipDamageRoller.modRoll);
	-- ActionsManager.registerModHandler("msdamage10", MothershipDamageRoller.modRoll);
	ActionsManager.registerResultHandler("msdamage", onDamage);
	ActionsManager.registerResultHandler("msdamage10", onDamage);
end

function handleApplyDamage(msgOOB)
	-- local rSource = ActorManager.getActor(msgOOB.sSourceType, msgOOB.sSourceNode);
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	-- local rTarget = ActorManager.getActor(msgOOB.sTargetType, msgOOB.sTargetNode);
	local rTarget = ActorManager.resolveActor(msgOOB.sTargetNode);
	if rTarget then
		rTarget.nOrder = msgOOB.nTargetOrder;
	end

	local nTotal = tonumber(msgOOB.nTotal) or 0;
	applyDamage(rSource, rTarget, (tonumber(msgOOB.nSecret) == 1), msgOOB.sDamage, nTotal);
end

function notifyApplyDamage(rSource, rTarget, bSecret, sDesc, nTotal)
	if not rTarget then
		return;
	end
	local sTargetType, sTargetNode = ActorManager.getTypeAndNodeName(rTarget);
	if sTargetType ~= "pc" and sTargetType ~= "ct" then
		return;
	end

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYDMG;
	
	if bSecret then
		msgOOB.nSecret = 1;
	else
		msgOOB.nSecret = 0;
	end
	msgOOB.nTotal = nTotal;
	msgOOB.sDamage = sDesc;
	msgOOB.sTargetType = sTargetType;
	msgOOB.sTargetNode = sTargetNode;
	msgOOB.nTargetOrder = rTarget.nOrder;

	local sSourceType, sSourceNode = ActorManager.getTypeAndNodeName(rSource);
	msgOOB.sSourceType = sSourceType;
	msgOOB.sSourceNode = sSourceNode;

	Comm.deliverOOBMessage(msgOOB, "");
end

function performRoll(draginfo, rActor, rAction)
	local rRoll = getRoll(rActor, rAction);
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, rAction)
	local rRoll = {};
	rRoll.sType = "msdamage";
	rRoll.aDice = {};
	rRoll.nMod = rAction.modifier or 0;
	
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	local nCurrentWounds = math.max(DB.getValue(nodeActor, "maxwounds", 0) - DB.getValue(nodeActor, "wounds", 0), 0);
	rAction.damage = rAction.damage:gsub("Current Wounds", nCurrentWounds);
	rAction.damage = rAction.damage:gsub(" %+ Wounds", "%+" .. nCurrentWounds);

	local sDice,sDamageType = string.match(rAction.damage, "([^%s_]+)%s+(%a+)");
	local aDice,nMod = StringManager.convertStringToDice(sDice);
	local bIsADV = rAction.damage:match("%[%+%]");
	local bIsAntiArmor = rAction.damage:match("%(AA%)");

	rRoll.aDice = aDice;
	rRoll.nMod = nMod;
	rRoll.sDesc = StringManager.trim("[DAMAGE] " .. (rAction.label or "")) .. " " .. sDice;
	if string.match(sDamageType, "Wounds?") then
		rRoll.sDesc = rRoll.sDesc .. " [WOUNDS]";
	end
	if bIsADV then
		rRoll.sDesc = rRoll.sDesc .. " [ADV]";
	end
	if bIsAntiArmor then
		rRoll.sDesc = rRoll.sDesc .. " [AA]";
	end
	rRoll.sDesc = rRoll.sDesc .. " [CRIT: " .. rAction.sCrit .. "]";
	if rAction.bIsBleed then
		rRoll.sDesc = rRoll.sDesc .. " [BLEED]";
	end
	
	return rRoll;
end

function onDamage(rSource, rTarget, rRoll)
	MothershipDamageRoller.onRoll(rSource, rTarget, rRoll);

	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

	rRoll.nTotal = math.max(rRoll.nTotal, 0)
	
	-- Apply damage to the PC or CT entry referenced
	notifyApplyDamage(rSource, rTarget, rRoll.bTower, rMessage.text, rRoll.nTotal);
end

function decodeDamageText(nDamage, sDamageDesc)
	local rDamageOutput = {};
	
	if string.match(sDamageDesc, "%[RECOVERY") then
		rDamageOutput.sType = "recovery";
		rDamageOutput.sTypeOutput = "Recovery";
		rDamageOutput.sVal = string.format("%01d", nDamage);
		rDamageOutput.nVal = nDamage;

	elseif string.match(sDamageDesc, "%[HEAL") then
		if string.match(sDamageDesc, "%[TEMP%]") then
			rDamageOutput.sType = "temphp";
			rDamageOutput.sTypeOutput = "Temporary hit points";
		else
			rDamageOutput.sType = "heal";
			rDamageOutput.sTypeOutput = "Heal";
		end
		rDamageOutput.sVal = string.format("%01d", nDamage);
		rDamageOutput.nVal = nDamage;

	elseif nDamage < 0 then
		rDamageOutput.sType = "heal";
		rDamageOutput.sTypeOutput = "Heal";
		rDamageOutput.sVal = string.format("%01d", (0 - nDamage));
		rDamageOutput.nVal = 0 - nDamage;

	else
		rDamageOutput.sType = "msdamage";
		rDamageOutput.sTypeOutput = "Damage";
		rDamageOutput.sVal = string.format("%01d", nDamage);
		rDamageOutput.nVal = nDamage;

		-- Determine critical
		rDamageOutput.bCritical = string.match(sDamageDesc, "%[CRITICAL%]");

		-- Determine damage type
		rDamageOutput.bWounds = string.match(sDamageDesc, "%[WOUNDS%]");
		rDamageOutput.bIsAntiArmor = string.match(sDamageDesc, "%[AA%]");

		-- Determine range
		rDamageOutput.sRange = string.match(sDamageDesc, "%[DAMAGE %((%w)%)%]") or "";
		rDamageOutput.aDamageFilter = {};
		-- if rDamageOutput.sRange == "M" then
			-- table.insert(rDamageOutput.aDamageFilter, "melee");
		-- elseif rDamageOutput.sRange == "R" then
			-- table.insert(rDamageOutput.aDamageFilter, "ranged");
		-- end

		-- Determine damage energy types
		local nDamageRemaining = nDamage;
		rDamageOutput.aDamageTypes = {};
		for sDamageType, sDamageDice, sDamageSubTotal in string.gmatch(sDamageDesc, "%[TYPE: ([^(]*) %(([%d%+%-dD]+)%=(%d+)%)%]") do
			local nDamageSubTotal = (tonumber(sDamageSubTotal) or 0);
			rDamageOutput.aDamageTypes[sDamageType] = nDamageSubTotal + (rDamageOutput.aDamageTypes[sDamageType] or 0);
			if not rDamageOutput.sFirstDamageType then
				rDamageOutput.sFirstDamageType = sDamageType;
			end
			
			nDamageRemaining = nDamageRemaining - nDamageSubTotal;
		end
		if nDamageRemaining > 0 then
			rDamageOutput.aDamageTypes[""] = nDamageRemaining;
		elseif nDamageRemaining < 0 then
			ChatManager.SystemMessage("Total mismatch in damage type totals");
		end
	end
	
	return rDamageOutput;
end

function applyDamage(rSource, rTarget, bSecret, sDamage, nTotal)
	local sTargetType, nodeTarget = ActorManager.getTypeAndNode(rTarget);
	if sTargetType ~= "pc" and sTargetType ~= "ct" then
		return;
	end

	local nMaxWounds = DB.getValue(nodeTarget, "maxwounds", 0);
	local nWounds = DB.getValue(nodeTarget, "wounds", 0);
	local nHealth = DB.getValue(nodeTarget, "health", 0);
	local nInjury = DB.getValue(nodeTarget, "injury", 0);
	local nArmorPoints = DB.getValue(nodeTarget, "armorpoints", 0);
	local nDamageReduction = DB.getValue(nodeTarget, "damagereduction", 0);

	local aNotifications = {};

	local _,sOriginalStatus = ActorManager2.getPercentWounded(rTarget);

	local rDamageOutput = decodeDamageText(nTotal, sDamage);

	-- Contractors
	local bIsContractor = nHealth == 0;
	if bIsContractor and (not rDamageOutput.bWounds) and (nTotal - nArmorPoints > 0 or string.match(sDamage, "%[BLEED%]") or rDamageOutput.bIsAntiArmor) then
		rDamageOutput.bWounds = true;
		nTotal = 1;
	end
	
	-- Wounds
	if rDamageOutput.bWounds then
		nTotal = nTotal * math.max(nHealth, 1);
	end
	
	-- Healing
	if rDamageOutput.sType == "heal" then
		if nInjury <= 0 then
			table.insert(aNotifications, "[NOT WOUNDED]");
		else
			-- Calculate heal amounts
			local nHealAmount = rDamageOutput.nVal;
			
			-- If healing from zero (or negative), then remove Stable effect and reset wounds to match HP
			if (nHealAmount > 0) and (nInjury >= nHealth) then
				EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Stable");
				nInjury = nHealth;
			end
			
			local nWoundHealAmount = math.min(nHealAmount, nInjury);
			nInjury = nInjury - nWoundHealAmount;
			
			-- Display actual heal amount
			rDamageOutput.nVal = nWoundHealAmount;
			rDamageOutput.sVal = string.format("%01d", nWoundHealAmount);
		end
	-- Damage
	else
		-- Apply any targeted damage effects 
		-- NOTE: Dice determined randomly, instead of rolled
		-- if rSource and rTarget and rTarget.nOrder then
			-- local bCritical = string.match(sDamage, "%[CRITICAL%]");
			-- local aTargetedDamage = EffectManager5E.getEffectsBonusByType(rSource, {"DMG"}, true, rDamageOutput.aDamageFilter, rTarget, true);

			-- local nDamageEffectTotal = 0;
			-- local nDamageEffectCount = 0;
			-- for k, v in pairs(aTargetedDamage) do
				-- local bValid = true;
				-- local aSplitByDmgType = StringManager.split(k, ",", true);
				-- for _,vDmgType in ipairs(aSplitByDmgType) do
					-- if vDmgType == "critical" and not bCritical then
						-- bValid = false;
					-- end
				-- end
				
				-- if bValid then
					-- local nSubTotal = StringManager.evalDice(v.dice, v.mod);
					
					-- local sDamageType = rDamageOutput.sFirstDamageType;
					-- if sDamageType then
						-- sDamageType = sDamageType .. "," .. k;
					-- else
						-- sDamageType = k;
					-- end

					-- rDamageOutput.aDamageTypes[sDamageType] = (rDamageOutput.aDamageTypes[sDamageType] or 0) + nSubTotal;
					
					-- nDamageEffectTotal = nDamageEffectTotal + nSubTotal;
					-- nDamageEffectCount = nDamageEffectCount + 1;
				-- end
			-- end
			-- nTotal = nTotal + nDamageEffectTotal;

			-- if nDamageEffectCount > 0 then
				-- if nDamageEffectTotal ~= 0 then
					-- local sFormat = "[" .. Interface.getString("effects_tag") .. " %+d]";
					-- table.insert(aNotifications, string.format(sFormat, nDamageEffectTotal));
				-- else
					-- table.insert(aNotifications, "[" .. Interface.getString("effects_tag") .. "]");
				-- end
			-- end
		-- end
		
		-- Handle avoidance/evasion and half damage
		-- local isAvoided = false;
		-- local isHalf = string.match(sDamage, "%[HALF%]");
		-- local sAttack = string.match(sDamage, "%[DAMAGE[^]]*%] ([^[]+)");
		-- if sAttack then
			-- local sDamageState = getDamageState(rSource, rTarget, StringManager.trim(sAttack));
			-- if sDamageState == "none" then
				-- isAvoided = true;
				-- bRemoveTarget = true;
			-- elseif sDamageState == "half_success" then
				-- isHalf = true;
				-- bRemoveTarget = true;
			-- elseif sDamageState == "half_failure" then
				-- isHalf = true;
			-- end
		-- end
		-- if isAvoided then
			-- table.insert(aNotifications, "[EVADED]");
			-- for kType, nType in pairs(rDamageOutput.aDamageTypes) do
				-- rDamageOutput.aDamageTypes[kType] = 0;
			-- end
			-- nTotal = 0;
		-- elseif isHalf then
			-- table.insert(aNotifications, "[HALF]");
			-- local bCarry = false;
			-- for kType, nType in pairs(rDamageOutput.aDamageTypes) do
				-- local nOddCheck = nType % 2;
				-- rDamageOutput.aDamageTypes[kType] = math.floor(nType / 2);
				-- if nOddCheck == 1 then
					-- if bCarry then
						-- rDamageOutput.aDamageTypes[kType] = rDamageOutput.aDamageTypes[kType] + 1;
						-- bCarry = false;
					-- else
						-- bCarry = true;
					-- end
				-- end
			-- end
			-- nTotal = math.max(math.floor(nTotal / 2), 1);
		-- end
		
		-- Apply damage type adjustments
		-- local nDamageAdjust, bVulnerable, bResist = getDamageAdjust(rSource, rTarget, nTotal, rDamageOutput);
		-- local nAdjustedDamage = nTotal + nDamageAdjust;
		-- if nAdjustedDamage < 0 then
			-- nAdjustedDamage = 0;
		-- end
		-- if bResist then
			-- if nAdjustedDamage <= 0 then
				-- table.insert(aNotifications, "[RESISTED]");
			-- else
				-- table.insert(aNotifications, "[PARTIALLY RESISTED]");
			-- end
		-- end
		-- if bVulnerable then
			-- table.insert(aNotifications, "[VULNERABLE]");
		-- end
		
		-- Reduce damage by temporary hit points
		-- if nTempHP > 0 and nAdjustedDamage > 0 then
			-- if nAdjustedDamage > nTempHP then
				-- nAdjustedDamage = nAdjustedDamage - nTempHP;
				-- nTempHP = 0;
				-- table.insert(aNotifications, "[PARTIALLY ABSORBED]");
			-- else
				-- nTempHP = nTempHP - nAdjustedDamage;
				-- nAdjustedDamage = 0;
				-- table.insert(aNotifications, "[ABSORBED]");
			-- end
		-- end

		local nRemainder = nTotal;

		-- Apply armor
		if not string.match(sDamage, "%[BLEED%]") then
			if nDamageReduction > 0 then
				nRemainder = math.max(nRemainder - nDamageReduction, 0);
				table.insert(aNotifications, "[ARMOR REDUCED DAMAGE BY " .. nDamageReduction .. "]");
			end
			if nRemainder > 0 then
				if rDamageOutput.bWounds then
					-- local bIgnoreFirstWound, vArmor = CharArmorManager.getIgnoreFirstWound(nodeTarget);
					-- if bIgnoreFirstWound then
						-- nRemainder = nRemainder - nHealth;
						-- if OptionsManager.getOption("HRARM") == "on" then
							-- CharArmorManager.disableIgnoreFirstWound(vArmor);
						-- end
						-- table.insert(aNotifications, "[FIRST WOUND IGNORED]");
					-- end
				elseif nArmorPoints > 0 and not rDamageOutput.bIsAntiArmor then
					nRemainder = math.max(nRemainder - nArmorPoints, 0);
					table.insert(aNotifications, "[ARMOR BLOCKED " .. (nTotal - nDamageReduction - nRemainder) .. " DAMAGE]");
				end			
				if nRemainder > 0 and nArmorPoints > 0 then
					if OptionsManager.getOption("HRARM") == "on" then
						if bIsContractor then
							DB.setValue(nodeTarget, "armorpoints", "number", 0);
						else
							CharArmorManager.destroyArmor(nodeTarget);
						end
					end
					table.insert(aNotifications, "[ARMOR DESTROYED]");
				end
			end
		end
		
		-- Apply remaining damage
		while (nRemainder > 0)
		do
			local bWounded = false;
			
			-- Remember previous injury
			local nPrevInjury = nInjury;
			
			-- Apply injury
			nInjury = math.max(nInjury + nRemainder, 0);

			-- Calculate injury above health
			if nInjury >= nHealth then
				nRemainder = nInjury - math.max(nHealth, 1);
				nInjury = nHealth;
				nWounds = nWounds + 1;
				bWounded = true;
			else
				nRemainder = 0;
			end
			
			-- if bWounded and bIgnoreFirstWound then
				-- table.insert(aNotifications, "[WOUND IGNORED]");
				-- bWounded = false;
				-- bIgnoreFirstWound = false;
			-- end

			if bWounded then
				local bFatalInjury;
				
				if sTargetType == "pc" then
					if OptionsManager.getOption("HRWND") == "on" and sDamage:match('%[CRIT:') then
						local aAllResults = WoundManager.getWoundResults(sDamage:gsub('%[([%+%-])%]', '{%1}'):match('%[CRIT: ([%a%c%p%s]-)%]'):gsub('{([%+%-])}', '[%1]'));						
						for _,aResults in pairs(aAllResults) do
							table.insert(aNotifications, "[WOUND: " .. aResults[1].sText .. " - " .. aResults[2].sText .. "]");

							if OptionsManager.getOption("HREFF") == "on" then
								local sEffects = applyWoundEffects(nodeTarget, aResults[2].sText);
								if sEffects ~= "" then
									table.insert(aNotifications, sEffects);
								end
							end

							bFatalInjury = aResults[1].sText == "Fatal Injury";
							if bFatalInjury then
								nWounds = nMaxWounds;
								nRemainder = 0;
							end
						end
					else
						table.insert(aNotifications, "[ROLL WOUND]");				
					end
				else
					table.insert(aNotifications, "[WOUND]");				
				end
				
				if nWounds < nMaxWounds then
					nInjury = 0;
				elseif not bFatalInjury then
					nRemainder = 0;
					if sTargetType == "pc" then
						-- if OptionsManager.getOption("HRWND") == "on" then
							-- aResults = TableManager.getResults(TableManager.findTable("Final Wound"), math.random(10) - 1, 0);
							-- table.insert(aNotifications, "[FINAL WOUND: " .. aResults[1].sText .. "]");
						-- else
							table.insert(aNotifications, "[ROLL DEATH SAVE]");				
						-- end
					end
				end
			end
		end
		
		-- Update the damage output variable to reflect adjustments
		rDamageOutput.nVal = nTotal;
		rDamageOutput.sVal = string.format("%01d", nTotal);
	end

	-- Set health fields
	-- if sTargetType == "pc" then
		DB.setValue(nodeTarget, "injury", "number", nInjury);
		DB.setValue(nodeTarget, "wounds", "number", nWounds);
	-- else
		-- DB.setValue(nodeTarget, "injury", "number", nInjury);
	-- end

	local bShowStatus = false;
	if ActorManager.getFaction(rTarget) == "friend" then
		bShowStatus = not OptionsManager.isOption("SHPC", "off");
	else
		bShowStatus = not OptionsManager.isOption("SHNPC", "off");
	end
	if bShowStatus then
		local _,sNewStatus = ActorManager2.getPercentWounded(rTarget);
		-- if sOriginalStatus ~= sNewStatus then
			table.insert(aNotifications, "[" .. Interface.getString("combat_tag_status") .. ": " .. sNewStatus .. "]");
		-- end
	end
	
	-- Output results
	messageDamage(rSource, rTarget, bSecret, rDamageOutput.sTypeOutput, sDamage, rDamageOutput.bWounds, rDamageOutput.sVal, table.concat(aNotifications, " "));

	-- Remove target after applying damage
	-- if bRemoveTarget and rSource and rTarget then
		-- TargetingManager.removeTarget(ActorManager.getCTNodeName(rSource), ActorManager.getCTNodeName(rTarget));
	-- end
end

function messageDamage(rSource, rTarget, bSecret, sDamageType, sDamageDesc, bWounds, sTotal, sExtraResult)
	if not (rTarget or sExtraResult ~= "") then
		return;
	end
	local sTargetType, nodeTarget = ActorManager.getTypeAndNode(rTarget);

	local msgShort = {font = "msgfont"};
	local msgLong = {font = "msgfont"};

	-- if sDamageType == "Recovery" then
		-- msgShort.icon = "roll_heal";
		-- msgLong.icon = "roll_heal";
	-- elseif sDamageType == "Heal" then
		-- msgShort.icon = "roll_heal";
		-- msgLong.icon = "roll_heal";
	-- else
		msgShort.icon = "roll_damage";
		msgLong.icon = "roll_damage";
	-- end

	msgShort.text = sDamageType .. " ->";
	if bWounds then
		-- sTotal = sTotal .. "W";
		sTotal = math.floor(tonumber(sTotal) / math.max(DB.getValue(nodeTarget, "health", 0), 1)) .. "W";
	end
	msgLong.text = sDamageType .. " [" .. sTotal .. "] ->";
	if rTarget then
		msgShort.text = msgShort.text .. " [to " .. ActorManager.getDisplayName(rTarget) .. "]";
		msgLong.text = msgLong.text .. " [to " .. ActorManager.getDisplayName(rTarget) .. "]";
	end
	
	if sExtraResult and sExtraResult ~= "" then
		msgLong.text = msgLong.text .. " " .. sExtraResult;
	end
	
	ActionsManager.outputResult(bSecret, rSource, rTarget, msgLong, msgShort);
end

--
-- TRACK DAMAGE STATE
--

-- local aDamageState = {};

-- function applyDamageState(rSource, rTarget, sAttack, sState)
	-- local msgOOB = {};
	-- msgOOB.type = OOB_MSGTYPE_APPLYDMGSTATE;
	
	-- msgOOB.sSourceNode = ActorManager.getCTNodeName(rSource);
	-- msgOOB.sTargetNode = ActorManager.getCTNodeName(rTarget);
	
	-- msgOOB.sAttack = sAttack;
	-- msgOOB.sState = sState;

	-- Comm.deliverOOBMessage(msgOOB, "");
-- end

-- function handleApplyDamageState(msgOOB)
	-- local rSource = ActorManager.getActor("ct", msgOOB.sSourceNode);
	-- local rTarget = ActorManager.getActor("ct", msgOOB.sTargetNode);
	
	-- if User.isHost() then
		-- setDamageState(rSource, rTarget, msgOOB.sAttack, msgOOB.sState);
	-- end
-- end

-- function setDamageState(rSource, rTarget, sAttack, sState)
	-- if not User.isHost() then
		-- applyDamageState(rSource, rTarget, sAttack, sState);
		-- return;
	-- end
	
	-- local sSourceCT = ActorManager.getCTNodeName(rSource);
	-- local sTargetCT = ActorManager.getCTNodeName(rTarget);
	-- if sSourceCT == "" or sTargetCT == "" then
		-- return;
	-- end
	
	-- if not aDamageState[sSourceCT] then
		-- aDamageState[sSourceCT] = {};
	-- end
	-- if not aDamageState[sSourceCT][sAttack] then
		-- aDamageState[sSourceCT][sAttack] = {};
	-- end
	-- if not aDamageState[sSourceCT][sAttack][sTargetCT] then
		-- aDamageState[sSourceCT][sAttack][sTargetCT] = {};
	-- end
	-- aDamageState[sSourceCT][sAttack][sTargetCT] = sState;
-- end

-- function getDamageState(rSource, rTarget, sAttack)
	-- local sSourceCT = ActorManager.getCTNodeName(rSource);
	-- local sTargetCT = ActorManager.getCTNodeName(rTarget);
	-- if sSourceCT == "" or sTargetCT == "" then
		-- return "";
	-- end
	
	-- if not aDamageState[sSourceCT] then
		-- return "";
	-- end
	-- if not aDamageState[sSourceCT][sAttack] then
		-- return "";
	-- end
	-- if not aDamageState[sSourceCT][sAttack][sTargetCT] then
		-- return "";
	-- end
	
	-- local sState = aDamageState[sSourceCT][sAttack][sTargetCT];
	-- aDamageState[sSourceCT][sAttack][sTargetCT] = nil;
	-- return sState;
-- end

function applyWoundEffects(nodeTarget, sWoundEffect)
	local sText = "";

	-- if sTargetType == "pc" then
		local nBleeding = sWoundEffect:match("Bleeding %+(%d+)%.");
		if nBleeding then
			if OptionsManager.getOption("HREFF") == "on" then
				DB.setValue(nodeTarget, "bleeding", "number", DB.getValue(nodeTarget, "bleeding", 0) + nBleeding);
			end
			sText = sText .. " [+" .. nBleeding .. " BLEEDING]";
		end

		if sWoundEffect:match("%. Gain 1d5 Stress%.") then
			local nStress = DB.getValue(nodeTarget, "stress", 0);
			local nStressGain = math.random(5);
			local nExcess = nStress + nStressGain - DataCommon.maxstress;
			if OptionsManager.getOption("HREFF") == "on" and OptionsManager.getOption("HRSTR") == "on" then
				DB.setValue(nodeTarget, "stress", "number", math.min(nStress + nStressGain, DataCommon.maxstress));
			end
			sText = sText .. " [+" .. nStressGain - nExcess .. " STRESS]";
			if nExcess > 0 then
				sText = sText .. " [MAX STRESS EXCEEDED BY " .. nExcess .. ", CONVERT TO STAT/SAVE LOSS]";
			end
		end
	
		if sWoundEffect:match("%. %+1 Minimum Stress%.") then
			local nMinStress = DB.getValue(nodeSource, "minstress", 0);
			if nMinStress < DataCommon.maxstress then
				nMinStress = nMinStress + 1;
				local nStress = math.max(DB.getValue(nodeTarget, "stress", 0), nMinStress);
				if OptionsManager.getOption("HREFF") == "on" and OptionsManager.getOption("HRSTR") == "on" then
					DB.setValue(nodeTarget, "stress", "number", nStress);
					DB.setValue(nodeTarget, "minstress", "number", nMinStress);
				end
				sText = sText .. " [+1 MIN STRESS]";
			else
				sText = sText .. " [MAX STRESS EXCEEDED]";
			end
		end
			
		if sWoundEffect:match("%. %-1d10 Strength%.") then
			local nStrengthLoss = math.random(10);
			if OptionsManager.getOption("HREFF") == "on" then
				DB.setValue(nodeTarget, "stats.strength", "number", math.min(DB.getValue(nodeTarget, "stats.strength", 0) - nStrengthLoss, 0));
			end
			sText = sText .. " [-" .. nStrengthLoss .. " STRENGTH]";
		end
		
		if sWoundEffect:match("%. %-2d10 Body Save%.") then
			local nBodySaveLoss = DiceManagerMothership.getDiceResult(2,10);
			if OptionsManager.getOption("HREFF") == "on" then
				DB.setValue(nodeTarget, "saves.body", "number", math.min(DB.getValue(nodeTarget, "saves.body", 0) - nBodySaveLoss, 0));
			end
			sText = sText .. " [-" .. nBodySaveLoss .. " BODY SAVE]";
		end
	-- end
	
	sText = sText:gsub("^%s*", "");
	return sText;
end
