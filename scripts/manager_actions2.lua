-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function encodeSafety(rRoll)
	if ModifierStack.getModifierKey("SAFE") then
		rRoll.sDesc = rRoll.sDesc .. " [SAFE]";
	end
end

function getSafety(rRoll)
	return string.match(rRoll.sDesc, "%[SAFE%]");
end

function encodeDesktopMods(rRoll)
	local nMod = 0;

	if ModifierStack.getModifierKey("PLUS5") then
		nMod = nMod + 5;
	end
	if ModifierStack.getModifierKey("MINUS5") then
		nMod = nMod - 5;
	end
	if ModifierStack.getModifierKey("PLUS10") then
		nMod = nMod + 10;
	end
	if ModifierStack.getModifierKey("MINUS10") then
		nMod = nMod - 10;
	end
	if ModifierStack.getModifierKey("MINUS25") then
		nMod = nMod - 25;
	end
	
	if nMod == 0 then
		return;
	end
	
	rRoll.nMod = rRoll.nMod + nMod;
	rRoll.sDesc = rRoll.sDesc .. string.format(" [%+d]", nMod);
end

function encodeAdvantage(rRoll, bADV, bDIS)
	local bButtonADV = ModifierStack.getModifierKey("ADV");
	local bButtonDIS = ModifierStack.getModifierKey("DIS");
	if bButtonADV then
		bADV = true;
	end
	if bButtonDIS then
		bDIS = true;
	end
	
	if bADV then
		rRoll.sDesc = rRoll.sDesc .. " [ADV]";
	end
	if bDIS then
		rRoll.sDesc = rRoll.sDesc .. " [DIS]";
	end
	if (bADV and not bDIS) or (bDIS and not bADV) then
		if #(rRoll.aDice) > 0 then
			for i = #(rRoll.aDice), 1, -1 do
				table.insert(rRoll.aDice, i + 1, rRoll.aDice[i]);
			end
		end
		rRoll.aDice.expr = nil;
	end
end

function decodeAdvantage(rRoll, nRollUnder, fAdvantage)
	local bADV = string.match(rRoll.sDesc, "%[ADV%]");
	local bDIS = string.match(rRoll.sDesc, "%[DIS%]");
	local bDropped = string.match(rRoll.sDesc, "%s%[DROPPED%s");

	if ((bADV and not bDIS) or (bDIS and not bADV)) and not bDropped then
		if (#(rRoll.aDice) > 0) and (#(rRoll.aDice) % 2 == 0) then
			local nTotal1, nTotal2, nDroppedTotal = 0, 0, 0;
			local bKeepFirst;
			
			for i = #(rRoll.aDice) - 1, 1, -2 do
				nTotal1 = nTotal1 + (rRoll.aDice[i].result);
				nTotal2 = nTotal2 + (rRoll.aDice[i + 1].result);
			end
			
			if not fAdvantage then
				fAdvantage = evaluateAdvantage;
			end
			nDroppedTotal = fAdvantage(rRoll, nTotal1, nTotal2, nRollUnder, bADV);
			bKeepFirst = (nTotal1 ~= nDroppedTotal);

			for i = #(rRoll.aDice) - 1, 1, -2 do
				if bKeepFirst then
					table.remove(rRoll.aDice, i + 1);
				else
					table.remove(rRoll.aDice, i);
				end
			end

			rRoll.sDesc = rRoll.sDesc .. " [DROPPED " .. nDroppedTotal .. "]";
		end
	end	
end

function evaluateAdvantage(rRoll, nFirst, nSecond, nRollUnder, bDIS)
	if bDIS then
		return math.min(nFirst, nSecond);
	else
		return math.max(nFirst, nSecond);
	end
end

function total(rRoll)
	local nTotal = 0;

	if #rRoll.aDice > 0 then
		for _,v in ipairs(rRoll.aDice) do
			if bUseFGUDiceValues and v.value then
				nTotal = nTotal + v.value;
			else
				nTotal = nTotal + v.result;
			end
		end
	else
		nTotal = rRoll.nMod;
	end
	
	return nTotal;
end
