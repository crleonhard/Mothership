
function onInit()
	-- GameSystem.currencies = { "cr", "kcr" };
	-- GameSystem.currencyDefault = "cr";
	
	ItemManager.isPack = ItemManager_isPack;
	
	PartyLootManager.addCoinsToPC = PartyLootManager_addCoinsToPC;
	PartyLootManager.buildPartyCoins = PartyLootManager_buildPartyCoins;
	PartyLootManager.distributeParcelCoins = PartyLootManager_distributeParcelCoins;
	PartyLootManager.sellItems = PartyLootManager_sellItems;
	-- PartyManager2.awardXP = PartyManager2_awardXP;
	ActionsManager.applyModifiersAndRoll = ActionsManager_applyModifiersAndRoll;
	ActionsManager.decodeActors = ActionsManager_decodeActors;
	
	-- DecalManager.setDefault("images/decals/swk_decal.png@Mothership PSG");
	
end

function ItemManager_isPack(nodeRecord)
	return ItemManager2.isLoadout(nodeRecord);
end

function PartyLootManager_addCoinsToPC(nodeChar, sCoin, nCoin)
	if nodeChar then
		-- local nNewAmount = DB.getValue(nodeTarget, "amount", 0) + nCoin;
		-- DB.setValue(nodeTarget, "amount", "number", nNewAmount);
		-- DB.setValue(nodeTarget, "name", "string", sCoin);

		if sCoin:lower() == "kcr" then
			nCoin = nCoin * 1000;
		elseif sCoin:lower() == "mcr" then
			nCoin = nCoin * 1000000;
		elseif sCoin:lower() == "bcr" then
			nCoin = nCoin * 1000000000;
		elseif sCoin:lower() ~= "cr" then
			return;
		end
		
		nCoin = nCoin + DB.getValue(nodeChar, "credits.cr", 0);
		nCoin = nCoin + (DB.getValue(nodeChar, "credits.kcr", 0) * 1000);
		nCoin = nCoin + (DB.getValue(nodeChar, "credits.mcr", 0) * 1000000);
		nCoin = nCoin + (DB.getValue(nodeChar, "credits.bcr", 0) * 1000000000);
		
		local nBCR = math.floor(nCoin / 1000000000);
		local nMCR = math.floor((nCoin % 1000000000) / 1000000);
		local nKCR = math.floor((nCoin % 1000000) / 1000);
		local nCR = nCoin % 1000;

		DB.setValue(nodeChar, "credits.cr", "number", nCR);
		DB.setValue(nodeChar, "credits.kcr", "number", nKCR);
		DB.setValue(nodeChar, "credits.mcr", "number", nMCR);
		DB.setValue(nodeChar, "credits.bcr", "number", nBCR);
	end
end

function PartyLootManager_buildPartyCoins()
	for _,vCoin in pairs(DB.getChildren("partysheet.coinlist")) do
		vCoin.delete();
	end

	-- Determine members of party
	local aParty = {};
	for _,v in pairs(DB.getChildren("partysheet.partyinformation")) do
		local sClass, sRecord = DB.getValue(v, "link");
		if sClass == "charsheet" and sRecord then
			local nodePC = DB.findNode(sRecord);
			if nodePC then
				local sName = StringManager.trim(DB.getValue(v, "name", ""));
				table.insert(aParty, { name = sName, node = nodePC } );
			end
		end
	end
	
	-- Build a database of party coins
	local aCoinDB = {};
	for _,v in ipairs(aParty) do
		-- for _,nodeCoin in pairs(DB.getChildren(v.node, "coins")) do
		for _,sCoin in pairs(GameSystem.currencies) do
			-- local sCoin = DB.getValue(nodeCoin, "name", ""):upper();
			if sCoin ~= "" then
				-- local nCount = DB.getValue(nodeCoin, "amount", 0);
				local nCount = DB.getValue(v.node, "credits." .. sCoin, 0);
				if nCount > 0 then
					if aCoinDB[sCoin] then
						aCoinDB[sCoin].count = aCoinDB[sCoin].count + nCount;
						aCoinDB[sCoin].carriedby = string.format("%s, %s [%d]", aCoinDB[sCoin].carriedby, v.name, math.floor(nCount));
					else
						local aCoin = {};
						aCoin.count = nCount;
						aCoin.carriedby = string.format("%s [%d]", v.name, math.floor(nCount));
						aCoinDB[sCoin] = aCoin;
					end
				end
			end
		end
	end
	
	-- Create party sheet coin entries
	for sCoin, rCoin in pairs(aCoinDB) do
		local vGroupItem = DB.createChild("partysheet.coinlist");
		DB.setValue(vGroupItem, "amount", "number", rCoin.count);
		DB.setValue(vGroupItem, "name", "string", sCoin);
		DB.setValue(vGroupItem, "carriedby", "string", rCoin.carriedby);
	end
end

function PartyLootManager_distributeParcelCoins() 
	local nRemainder = 0;
	-- Determine coins in parcel
	local aParcelCoins = {};
	local nCoinEntries = 0;
	for _,vCoin in pairs(DB.getChildren("partysheet.treasureparcelcoinlist")) do
		-- local sCoin = DB.getValue(vCoin, "description", ""):upper();
		local sCoin = DB.getValue(vCoin, "description", ""):lower();
		local nCount = DB.getValue(vCoin, "amount", 0);
		if sCoin ~= "" and nCount > 0 then

			if sCoin == "bcr" then
				sCoin = "cr";
				nCount = nCount * 1000000000;
			elseif sCoin == "mcr" then
				sCoin = "cr";
				nCount = nCount * 1000000;
			elseif sCoin == "kcr" then
				sCoin = "cr";
				nCount = nCount * 1000;
			end

			if sCoin == "cr" then
				aParcelCoins[sCoin] = (aParcelCoins[sCoin] or 0) + nCount;
				nCoinEntries = nCoinEntries + 1;
			end
		end
	end
	if nCoinEntries == 0 then
		return;
	end
	
	-- Determine members of party
	local aParty = {};
	for _,v in pairs(DB.getChildren("partysheet.partyinformation")) do
		local sClass, sRecord = DB.getValue(v, "link");
		if sClass == "charsheet" and sRecord then
			local nodePC = DB.findNode(sRecord);
			if nodePC then
				local rMember = {};
				
				rMember.name = StringManager.trim(DB.getValue(v, "name", ""));
				rMember.node = nodePC;
				rMember.given = {};
				
				table.insert(aParty, rMember);
			end
		end
	end
	if #aParty == 0 then
		return;
	end
	
	-- Add party member split to their character sheet
	for sCoin, nCoin in pairs(aParcelCoins) do
		local nAverageSplit;
		if nCoin >= #aParty then
			nAverageSplit = math.floor(nCoin / #aParty);
			if sCoin == "cr" then
				nRemainder = nCoin % #aParty;
			end
		else
			nAverageSplit = 0;
		end
		
		for k,v in ipairs(aParty) do
			local nAmount = nAverageSplit;
			
			if nAmount > 0 then
				-- Add distribution amount to character
				PartyLootManager_addCoinsToPC(v.node, sCoin, nAmount);
				
				-- Track distribution amount for output message
				v.given[sCoin] = nAmount;
			end
		end
	end
	
	-- Output coin assignments
	local aPartyAmount = {};
	for sCoin, nCoin in pairs(aParcelCoins) do
		local nCoinGiven = nCoin - (nCoin % #aParty);
		table.insert(aPartyAmount, tostring(nCoinGiven) .. " " .. sCoin);
	end

	local msg = {font = "msgfont"};
	
	msg.icon = "coins";
	for _,v in ipairs(aParty) do
		local aMemberAmount = {};
		for sCoin, nCoin in pairs(v.given) do
			table.insert(aMemberAmount, tostring(nCoin) .. " " .. sCoin);
		end
		msg.text = "[" .. table.concat(aMemberAmount, ", ") .. "] -> " .. v.name;
		Comm.deliverChatMessage(msg);
	end
	
	msg.icon = "portrait_gm_token";
	msg.text = Interface.getString("ps_message_coindistributesuccess") .. " [" .. table.concat(aPartyAmount, ", ") .. "]";
	Comm.deliverChatMessage(msg);

	-- Reset parcel and party coin amounts
	for _,vCoin in pairs(DB.getChildren("partysheet.treasureparcelcoinlist")) do
		local sCoin = DB.getValue(vCoin, "description", ""):lower();
		if sCoin == "cr" then
			DB.setValue(vCoin, "amount", "number", nRemainder);
		elseif sCoin == "kcr" or sCoin == "mcr" or sCoin == "bcr" then
			DB.setValue(vCoin, "amount", "number", 0);
		-- else
			-- local nCoin = DB.getValue(vCoin, "amount", 0);
			-- nCoin = nCoin % #aParty;
			-- DB.setValue(vCoin, "amount", "number", nCoin);
		end
	end
	PartyLootManager.buildPartyCoins();
end

function PartyLootManager_sellItems()
	local nItemTotal = 0;
	local aSellTotal = {};
	local nSellPercentage = DB.getValue("partysheet.sellpercentage");
	
	for _,vItem in pairs(DB.getChildren("partysheet.treasureparcelitemlist")) do
		local sItem = ItemManager.getDisplayName(vItem, true);
		local sAssign = StringManager.trim(DB.getValue(vItem, "assign", ""));
		if sAssign == "" then
			local nCoin = 0;

			local sCost = DB.getValue(vItem, "cost", "");
			-- local sCoinValue, sCoin = string.match(sCost, "^%s*([%d,]+)%s*([^%d]*)$");
			local sCoinValue, sCoin = string.match(sCost, "^%s*([%d,%.]+)%s*([^%d]*)$");
			if not sCoinValue then -- look for currency prefix instead
				-- sCoin, sCoinValue = string.match(sCost, "^%s*([^%d]+)%s*([%d,]+)%s*$");
				sCoin, sCoinValue = string.match(sCost, "^%s*([^%d]+)%s*([%d,%.]+)%s*$");
			end
			if sCoinValue then
				sCoinValue = string.gsub(sCoinValue, ",", "");
				nCoin = tonumber(sCoinValue) or 0;
				
				sCoin = StringManager.trim(sCoin);
				if sCoin == "" then
					sCoin = "cr";
				end
			end
			
			if nCoin == 0 then
				local msg = {font = "systemfont"};
				msg.text = Interface.getString("ps_message_itemsellcostmissing") .. " [" .. sItem .. "]";
				Comm.addChatMessage(msg);
			else
				local nCount = math.max(DB.getValue(vItem, "count", 1), 1);
				-- local nItemSellTotal = math.floor(nCount * nCoin * nSellPercentage / 100);
				local nItemSellTotal = nCount * nCoin * nSellPercentage / 100;
				if nItemSellTotal <= 0 then
					local msg = {font = "systemfont"};
					msg.text = Interface.getString("ps_message_itemsellcostlow") .. " [" .. sItem .. "]";
					Comm.addChatMessage(msg);
				else
					ItemManager.handleCurrency("partysheet", sCoin, nItemSellTotal);
					aSellTotal[sCoin] = (aSellTotal[sCoin] or 0) + nItemSellTotal;
					nItemTotal = nItemTotal + nCount;
					
					vItem.delete();

					local msg = {font = "msgfont"};
					msg.text = Interface.getString("ps_message_itemsellsuccess") .. " [";
					if nCount > 1 then
						msg.text = msg.text .. "(" .. nCount .. "x) ";
					end
					msg.text = msg.text .. sItem .. "] -> [" .. nItemSellTotal;
					if sCoin ~= "" then
						msg.text = msg.text .. " " .. sCoin;
					end
					msg.text = msg.text .. "]";
					
					Comm.deliverChatMessage(msg);
				end
			end
		end
	end

	if nItemTotal > 0 then
		local aTotalOutput = {};
		for k,v in pairs(aSellTotal) do
			table.insert(aTotalOutput, tostring(v) .. " " .. k);
		end
		local msg = {font = "msgfont"};
		msg.icon = "portrait_gm_token";
		msg.text = tostring(nItemTotal) .. " item(s) sold for [" .. table.concat(aTotalOutput, ", ") .. "]";
		Comm.deliverChatMessage(msg);
	end
end

function ActionsManager_applyModifiersAndRoll(rSource, vTarget, bMultiTarget, rRoll)
	local rNewRoll = UtilityManager.copyDeep(rRoll);
	local nRollUnder = tonumber(string.match(rNewRoll.sDesc, "vs (%d+)]"));

	local bModStackUsed = false;
	if not (nRollUnder and (#rNewRoll.aDice == 0)) then
		if bMultiTarget then
			if vTarget and #vTarget == 1 then
				bModStackUsed = ActionsManager.applyModifiers(rSource, vTarget[1], rNewRoll);
			else
				-- Only apply non-target specific modifiers before roll
				bModStackUsed = ActionsManager.applyModifiers(rSource, nil, rNewRoll);
			end
		else
			bModStackUsed = ActionsManager.applyModifiers(rSource, vTarget, rNewRoll);
		end
	end

	-- add modifier stack to target number instead of to roll
	-- local nRollUnder = tonumber(string.match(rNewRoll.sDesc, "vs (%d+)]"));
	if nRollUnder and (rNewRoll.nMod ~= 0) and (#rNewRoll.aDice > 0) then
		rNewRoll.sDesc = rNewRoll.sDesc:gsub("vs " .. nRollUnder .. "]", "vs " .. (nRollUnder + rNewRoll.nMod) .. "]");
		rNewRoll.nMod = 0;
	end

-- if nStoredMod then
	-- rNewRoll.nMod = nStoredMod;
-- end
	
	ActionsManager.roll(rSource, vTarget, rNewRoll, bMultiTarget);
	
	return bModStackUsed;
end

function ActionsManager_decodeActors(draginfo)
	local rSource = nil;
	local aTargets = {};
	for k,v in ipairs(draginfo.getShortcutList()) do
		if k == 1 then
			rSource = ActorManager.resolveActor(v.recordname);
		else
			local rTarget = ActorManager.resolveActor(v.recordname);
			if rTarget then
				table.insert(aTargets, rTarget);
			end
		end
	end
	
	return rSource, aTargets;
end
