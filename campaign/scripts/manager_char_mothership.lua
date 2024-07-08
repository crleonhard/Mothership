-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	ItemManager.setCustomCharAdd(onCharItemAdd);
	ItemManager.setCustomCharRemove(onCharItemDelete);
end

function resolveRefNode(sRecord, sAltRecord)
    local nodeSource = DB.findNode(sRecord);
    if not nodeSource then
        local sRecordSansModule = StringManager.split(sRecord, "@")[1];
        nodeSource = DB.findNode(sRecordSansModule .. "@*");
        if not nodeSource then
			if sAltRecord == nil then
				ChatManager.SystemMessage(Interface.getString("char_error_missingreference") .. sRecord);
			else
				nodeSource = resolveRefNode(sAltRecord);
			end
        end
    end

    return nodeSource;
end

function addClassDB(nodeChar, sClass, sRecord)
	local nodeClass = resolveRefNode(sRecord);
    if not nodeClass then
        return;
    end

	if nodeChar.getChild("pcclass").getValue() ~= "" then
		ChatManager.SystemMessage(Interface.getString("char_error_addclass"));
		return;
	end

	nodeChar.getChild("pcclass").setValue(DB.getValue(nodeClass, "name", ""));
	DB.setValue(nodeChar, "pcclasslink", "windowreference", sClass, sRecord);

	modifyStats(nodeChar, nodeClass);
	modifySaves(nodeChar, nodeClass);
	
	DB.setValue(nodeChar, "maxwounds", "number", DB.getValue(nodeClass, "maxwounds", 1));
	outputUserMessage("char_message_maxwoundsadd", DB.getValue(nodeClass, "name", ""), DB.getValue(nodeChar, "name", ""));

	DB.setValue(nodeChar, "traumaresponse", "string", DB.getValue(nodeClass, "traumaresponse", ""));
	outputUserMessage("char_message_traumaadd", DB.getValue(nodeClass, "name", ""), DB.getValue(nodeChar, "name", ""));

	addClassSkills(nodeChar, nodeClass);

	if OptionsManager.getOption("HRLOA") == "on" then
		local sTable = DB.getValue(nodeClass, "name", "") .. " Loadouts";
		local nodeLoadouts = TableManager.findTable(sTable);
		if nodeLoadouts then
			local aResults = TableManager.getResults(nodeLoadouts, math.random(10) - 1, 0);
			local nodeInventory = nodeChar.createChild("inventorylist");
			ItemManager.addItemToList(nodeInventory, aResults[1].sClass, DB.findNode(aResults[1].sRecord));
			-- bugfix: invlist no longer inits on load, so calling calc here in case events not yet firing
			CharArmorManager.calcArmorTotal(nodeChar);
			outputUserMessage("char_message_loadoutadd", DB.getValue(nodeClass, "name", ""), DB.getValue(nodeChar, "name", ""));
		else
			Debug.console(Interface.getString("table_error_lookupfail") .. " (" .. sTable .. ")");
		end
	end
end;

function addClassTraumaResponse(nodeChar, sClass, sRecord)
	local nodeClass = resolveRefNode(sRecord);
    if not nodeClass then
        return;
    end

	DB.setValue(nodeChar, "traumaresponse", "string", DB.getValue(nodeClass, "traumaresponse", ""));
	outputUserMessage("char_message_traumaadd", DB.getValue(nodeClass, "name", ""), DB.getValue(nodeChar, "name", ""));
end;

function modifyStats(nodeChar, nodeClass)
	local nodeStatAdjustments = nodeClass.getChild("statadjustments");
	if not nodeStatAdjustments then
		return;
	end

	DB.setValue(nodeChar, "stats.strength", "number", DB.getValue(nodeChar, "stats.strength") + DB.getValue(nodeStatAdjustments, "strength"));
	DB.setValue(nodeChar, "stats.speed", "number", DB.getValue(nodeChar, "stats.speed") + DB.getValue(nodeStatAdjustments, "speed"));
	DB.setValue(nodeChar, "stats.intellect", "number", DB.getValue(nodeChar, "stats.intellect") + DB.getValue(nodeStatAdjustments, "intellect"));
	DB.setValue(nodeChar, "stats.combat", "number", DB.getValue(nodeChar, "stats.combat") + DB.getValue(nodeStatAdjustments, "combat"));

	local nAnyStatAdjustment = DB.getValue(nodeStatAdjustments, "any", 0);
	if nAnyStatAdjustment ~= 0 then
		local aStatOptions = { "Strength", "Speed", "Intellect", "Combat" };
		local sMessageType = "reduce";
		if nAnyStatAdjustment > 0 then
			sMessageType = "increase";
		end
		pickOption(nodeChar, aStatOptions, onStatOptionSelect, nAnyStatAdjustment, Interface.getString("char_build_title_selectstat"), string.format(Interface.getString("char_build_message_selectstat"), sMessageType));
	end
	
	outputUserMessage("char_message_statsadd", DB.getValue(nodeClass, "name", ""), DB.getValue(nodeChar, "name", ""));
end;

function modifySaves(nodeChar, nodeClass)
	local nodeSaveAdjustments = nodeClass.getChild("saveadjustments");
	if not nodeSaveAdjustments then
		return;
	end

	DB.setValue(nodeChar, "saves.sanity", "number", DB.getValue(nodeChar, "saves.sanity") + DB.getValue(nodeSaveAdjustments, "sanity"));
	DB.setValue(nodeChar, "saves.fear", "number", DB.getValue(nodeChar, "saves.fear") + DB.getValue(nodeSaveAdjustments, "fear"));
	DB.setValue(nodeChar, "saves.body", "number", DB.getValue(nodeChar, "saves.body") + DB.getValue(nodeSaveAdjustments, "body"));

	outputUserMessage("char_message_savesadd", DB.getValue(nodeClass, "name", ""), DB.getValue(nodeChar, "name", ""));
end;

function addClassSkills(nodeChar, nodeClass)
	local sClassSkills = DB.getValue(nodeClass, "skills", "");
	
	local aClassSkills, aClassSkillsStats = StringManager.split(sClassSkills, ".", true);
	for _,sSkillGroup in ipairs(aClassSkills) do
		if sSkillGroup:lower():match("1 master skill,? and an expert and trained skill prerequisite") then
			local aSkills = getAvailableSkills(nodeChar, "Master", true);
			pickSkills(nodeChar, aSkills, 1, pickExpertPrerequisite, string.format(Interface.getString("char_build_title_selectrankedskills"), "Master"));
		elseif sSkillGroup:lower():match("bonus: 1 expert skill or:? 2 trained skills") then
			aSkillOptions = { "1 Expert Skill", "2 Trained Skills" };
			pickSkillOption(nodeChar, aSkillOptions);
		elseif sSkillGroup:lower():match("bonus: 1 trained skill and 1 expert skill") then
			pickSkills(nodeChar, getAvailableSkills(nodeChar, "Trained"), 1, pickExpertSkill, string.format(Interface.getString("char_build_title_selectrankedskills"), "Trained"));
		elseif sSkillGroup:lower():match("bonus: 1 trained skill") then
			pickSkills(nodeChar, getAvailableSkills(nodeChar, "Trained"), 1, nil, string.format(Interface.getString("char_build_title_selectrankedskills"), "Trained"));
		else
			for sSkill in sSkillGroup:gmatch("(%a[%a%s%-]+)%,?") do
				addSkillDB(nodeChar, StringManager.trim(sSkill));		
			end
		end
	end
end

function getUnlockedSkillList(nodeChar)
	local sUnlocks = "";
	-- local nodeList = resolveRefNode("reference.skilldata@*");
	-- if not nodeList then
		-- nodeList = resolveRefNode("skill");
	-- end
	local nodeList = resolveRefNode("reference.skilldata", "skill");
	if nodeList then
		local aUnlocks = { ["Trained"] = { }, ["Expert"] = { }, ["Master"] = { }};
		for _,vSkill in pairs(nodeList.getChildren()) do
			local sSkill = DB.getValue(vSkill, "name", "");
			local sRank = DB.getValue(vSkill, "rank", "");
			if not CharManagerMothership.hasSkill(nodeChar, sSkill) then
				local sPrerequisites = DB.getValue(vSkill, "prerequisites", "");
				local aPrerequisites = StringManager.split(sPrerequisites:lower(), ",", true);
				if #aPrerequisites > 0 then
					for _,sPrerequisite in pairs(aPrerequisites) do
						if CharManagerMothership.hasSkill(nodeChar, sPrerequisite) then
							table.insert(aUnlocks[sRank], sSkill);
							break;
						end
					end
				else
					table.insert(aUnlocks[sRank], sSkill);
				end
			end
		end
		if #aUnlocks["Trained"] > 0 then
			table.sort(aUnlocks["Trained"]);
			sUnlocks = sUnlocks .. "[Trained] " .. table.concat(aUnlocks["Trained"], ", ") .. "\n";
		end
		if #aUnlocks["Expert"] > 0 then
			table.sort(aUnlocks["Expert"]);
			sUnlocks = sUnlocks .. "[Expert] " .. table.concat(aUnlocks["Expert"], ", ") .. "\n";
		end
		if #aUnlocks["Master"] > 0 then
			table.sort(aUnlocks["Master"]);
			sUnlocks = sUnlocks .. "[Master] " .. table.concat(aUnlocks["Master"], ", ") .. "\n";
		end
	end
	return sUnlocks:gsub("\n$", "");
end

function getAvailableSkills(nodeChar, sRankFilter, bIgnorePrerequisites)
	-- local nodeList = resolveRefNode("reference.skilldata@*");
	-- if not nodeList then
		-- nodeList = resolveRefNode("skill");
	-- end
	local nodeList = resolveRefNode("reference.skilldata", "skill");
	local aAvailableSkills = { };
	if nodeList then
		for _,vSkill in pairs(nodeList.getChildren()) do
			local sSkill = DB.getValue(vSkill, "name", "");
			local sRank = DB.getValue(vSkill, "rank", "");
			if (not sRankFilter) or sRank == sRankFilter then
				if not CharManagerMothership.hasSkill(nodeChar, sSkill) then
					local sPrerequisites = DB.getValue(vSkill, "prerequisites", "");
					local aPrerequisites = StringManager.split(sPrerequisites:lower(), ",", true);
					if #aPrerequisites > 0 and not bIgnorePrerequisites then
						for _,sPrerequisite in pairs(aPrerequisites) do
							if CharManagerMothership.hasSkill(nodeChar, sPrerequisite) then
								table.insert(aAvailableSkills, sSkill);
								break;
							end
						end
					else
						table.insert(aAvailableSkills, sSkill);
					end
				end
			end
		end
		table.sort(aAvailableSkills);
	end
	return aAvailableSkills;
end

function getSkillPrerequisites(sSkill, nodeChar, bKnown, sRankFilter)
	local aSkillPrerequisites = { };
	-- local nodeSkill = resolveRefNode("reference.skilldata." .. sSkill:gsub( "%W", "" ):lower() .. "@*");
	local nodeSkill = getSkillNode(sSkill);
	if nodeSkill then
		local aPrerequisites = StringManager.split(DB.getValue(nodeSkill, "prerequisites", ""), ",", true);
		if nodeChar and #aPrerequisites > 0 then
			for _,sPrerequisite in pairs(aPrerequisites) do
				if Logic.xor(CharManagerMothership.hasSkill(nodeChar, sPrerequisite), not bKnown) then
					-- local nodePrerequisite = resolveRefNode("reference.skilldata." .. sPrerequisite:gsub( "%W", "" ):lower() .. "@*");
					local nodePrerequisite = getSkillNode(sPrerequisite);
					if (not sRankFilter) or DB.getValue(nodePrerequisite, "rank", "") == sRankFilter then
						table.insert(aSkillPrerequisites, sPrerequisite);
					end
				end
			end
		else
			aSkillPrerequisites = aPrerequisites;
		end
		table.sort(aSkillPrerequisites)
	end
	return aSkillPrerequisites;
end

function addSkillDB(nodeChar, sSkill)
	local nodeList = nodeChar.createChild("skilllist");
	if not nodeList then
		return nil;
	end
	
	local nodeSkill = nil;
	for _,vSkill in pairs(nodeList.getChildren()) do
		if DB.getValue(vSkill, "name", "") == sSkill then
			nodeSkill = vSkill;
			break;
		end
	end

	if not nodeSkill then
		-- local nodeSource = resolveRefNode("reference.skilldata." .. sSkill:gsub( "%W", "" ):lower() .. "@*");
		local nodeSource = getSkillNode(sSkill);
		if nodeSource then
			nodeSkill = nodeList.createChild();
			DB.setValue(nodeSkill, "name", "string", sSkill);
			DB.setValue(nodeSkill, "bonus", "number", DataCommon.rank_bonus[DB.getValue(nodeSource, "rank"):lower()]);		
			DB.setValue(nodeSkill, "stat", "string", DB.getValue(nodeSource, "stat", ""):lower());
		end
	end

	if nodeSkill then
		outputUserMessage("char_message_skilladd", DB.getValue(nodeSkill, "name", ""), DB.getValue(nodeChar, "name", ""));
	else
		outputUserMessage("char_error_skilladd", sSkill);
	end
	
	return nodeSkill;
end

function getSkillNode(sSkill)
	-- local nodeList = resolveRefNode("reference.skilldata@*");
	-- if not nodeList then
		-- nodeList = resolveRefNode("skill");
		-- if not nodeList then
			-- return nil;
		-- end
	-- end
	local nodeList = resolveRefNode("reference.skilldata", "skill");
	if not nodeList then
		return nil;
	end
	
	local nodeSkill = nil;
	for _,vSkill in pairs(nodeList.getChildren()) do
		if DB.getValue(vSkill, "name", "") == sSkill then
			nodeSkill = vSkill;
			break;
		end
	end
	
	return nodeSkill;
end

function outputUserMessage(sResource, ...)
	local sFormat = Interface.getString(sResource);
	local sMsg = string.format(sFormat, ...);
	ChatManager.SystemMessage(sMsg);
end

function pickOption(nodeChar, aOptions, fnCallback, vCustom, sTitle, sMessage)
	local rOption = { nodeChar = nodeChar, custom = vCustom };
	local wSelect = Interface.openWindow("select_dialog", "");
	if not sTitle then
		sTitle = Interface.getString("dialog_title_selectoption");
	end
	if not sMessage then
		sMessage = Interface.getString("dialog_message_selectoption");
	end
	wSelect.requestSelection (sTitle, sMessage, aOptions, fnCallback, rOption, 1, 1);
end

function onStatOptionSelect(aSelection, rOption)
	if #aSelection > 0 then
		local sStat = aSelection[1]:lower();
		DB.setValue(rOption.nodeChar, "stats." .. sStat, "number", DB.getValue(rOption.nodeChar, "stats." .. sStat, 0) + rOption.custom);
	end
end

function pickSkillOption(nodeChar, aSkillOptions)
	local rSkillOption = { nodeChar = nodeChar };
	local wSelect = Interface.openWindow("select_dialog", "");
	local sTitle = Interface.getString("char_build_title_selectskilloption");
	local sMessage = Interface.getString("char_build_message_selectskilloption");
	wSelect.requestSelection (sTitle, sMessage, aSkillOptions, onSkillOptionSelect, rSkillOption, 1, 1);
end

function onSkillOptionSelect(aSelection, rSkillOption)
	if #aSelection > 0 then
		local sPicks, sRank = aSelection[1]:match("(%d+) (%w+) Skills?");
		local nPicks = (tonumber(sPicks) or 1);
		pickSkills(rSkillOption.nodeChar, getAvailableSkills(rSkillOption.nodeChar, sRank), nPicks, nil, string.format(Interface.getString("char_build_title_selectrankedskills"), sRank));
	end
end

function pickExpertSkill(rSkillAdd)
	pickSkills(rSkillAdd.nodeChar, getAvailableSkills(rSkillAdd.nodeChar, "Expert"), 1, nil, string.format(Interface.getString("char_build_title_selectrankedskills"), "Expert"));
end

function pickExpertPrerequisite(rSkillAdd)
	local sSelection = rSkillAdd.selection[1];
	local aPrerequisites = getSkillPrerequisites(sSelection, rSkillAdd.nodeChar, false, "Expert");
	if #aPrerequisites > 0 then
		pickSkills(rSkillAdd.nodeChar, aPrerequisites, 1, pickTrainedPrerequisite, string.format(Interface.getString("char_build_title_selectskillprerequisite"), "Expert"));
	end
end

function pickTrainedPrerequisite(rSkillAdd)
	local sSelection = rSkillAdd.selection[1];
	local aPrerequisites = getSkillPrerequisites(rSkillAdd.selection[1], rSkillAdd.nodeChar, false, "Trained");
	if #aPrerequisites > 0 then
		pickSkills(rSkillAdd.nodeChar, aPrerequisites, 1, nil, string.format(Interface.getString("char_build_title_selectskillprerequisite"), "Trained"));
	end
end

function pickSkills(nodeChar, aSkills, nPicks, fnNextStep, sTitle)
	if not aSkills then 
		aSkills = {}; 
	end
	if not sTitle then
		sTitle = Interface.getString("char_build_title_selectskills");
	end
	
	local rSkillAdd = { nodeChar = nodeChar, nextstep = fnNextStep };
	local wSelect = Interface.openWindow("select_dialog", "");
	local sPrompt = "";
	if nPicks > 1 then
		sPrompt = Interface.getString("char_build_message_selectskills");
	else
		sPrompt = Interface.getString("char_build_message_selectskill");
	end
	local sMessage = string.format(sPrompt, nPicks);
	wSelect.requestSelection (sTitle, sMessage, aSkills, onSkillSelect, rSkillAdd, nPicks, nPicks);
end

function onSkillSelect(aSelection, rSkillAdd)
	for _,sSkill in ipairs(aSelection) do
		addSkillDB(rSkillAdd.nodeChar, sSkill);
	end

	if rSkillAdd.nextstep then
		rSkillAdd.selection = aSelection;
		rSkillAdd.nextstep(rSkillAdd);
	end
end

--
-- ITEM/FOCUS MANAGEMENT
--

function onCharItemAdd(nodeItem)
	DB.setValue(nodeItem, "carried", "number", 1);
	
	CharArmorManager.addToArmorDB(nodeItem);
	CharWeaponManager.addToWeaponDB(nodeItem);
end

function onCharItemDelete(nodeItem)
	CharArmorManager.removeFromArmorDB(nodeItem);
	CharWeaponManager.removeFromWeaponDB(nodeItem);
end

function hasSkill(nodeChar, sSkill)
	return (getSkillRecord(nodeChar, sSkill) ~= nil);
end

function getSkillRecord(nodeChar, sSkill)
	if not sSkill then
		return nil;
	end
	local sSkillLower = sSkill:lower();
	for _,v in pairs(DB.getChildren(nodeChar, "skilllist")) do
		if DB.getValue(v, "name", ""):lower() == sSkillLower then
			return v;
		end
	end
	return nil;
end

--

function buildCheckAction(rActor, sStat, nRollUnder, sSkill)
	local rAction = {};
	rAction.sType = "check";
	rAction.label = StringManager.capitalize(sStat);
	if StringManager.contains(DataCommon.saves, sStat:lower()) then
		rAction.sType = "save";
		rAction.label = DataCommon.saves_display[sStat:lower()];
	end
	if sSkill then
		rAction.label = rAction.label .. " [" .. StringManager.capitalize(sSkill) .. "]";
	end
	rAction.nRollUnder = nRollUnder;
	return rAction;
end
