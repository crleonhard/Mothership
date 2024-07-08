-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	-- registerMenuItem(Interface.getString("list_menu_createitem"), "insert", 5);

	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "*.bonus"), "onUpdate", onSkillsChanged);
end

function onClose()
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "*.bonus"), "onUpdate", onSkillsChanged);
end

function onAbilityChanged()
	for _,w in ipairs(getWindows()) do
		-- if w.isCustom() then
			-- w.idelete.setVisibility(bEditMode);
		-- else
			w.idelete.setVisibility(false);
			w.idelete_spacer.setVisibility(true);
		-- end
	end
end

function onListChanged()
	update();
	
	local nodeChar = getDatabaseNode().getParent();
	window.unlocks.setValue(CharManagerMothership.getUnlockedSkillList(nodeChar));
	
	onSkillsChanged();
end

function onSkillsChanged()
	local nodeChar = getDatabaseNode().getParent();
	window.salary.setValue(getSalary(nodeChar) .. " cr");
end

function update()
	local bEditMode = (window.skills_iedit.getValue() == 1);
	-- window.idelete_header.setVisible(bEditMode);
	for _,w in ipairs(getWindows()) do
		-- if w.isCustom() then
			w.idelete.setVisibility(bEditMode);
			w.idelete_spacer.setVisible(not bEditMode);
		-- else
			-- w.idelete.setVisibility(false);
		-- end
	end
end

function addEntry(bFocus)
	local w = createWindow();
	w.setCustom(true);
	if bFocus and w then
		w.name.setFocus();
	end
	return w;
end

-- function onMenuSelection(item)
	-- if item == 5 then
		-- addEntry(true);
	-- end
-- end

function addSkillReference(nodeSource)
	if not nodeSource then
		return;
	end
	
	local sName = StringManager.trim(DB.getValue(nodeSource, "name", ""));
	if sName == "" then
		return;
	end
	
	-- check for prerequisite
	local sPrerequisites = DB.getValue(nodeSource, "prerequisites", "");
	local aPrerequisites = StringManager.split(sPrerequisites:lower(), ",", true);
	if #aPrerequisites > 0 then
		local wPrerequisite = nil;
		for _,w in pairs(getWindows()) do
			if StringManager.contains(aPrerequisites, StringManager.trim(w.name.getValue()):lower()) then
				wPrerequisite = w;
				break;
			end
		end
		if not wPrerequisite then
			if #aPrerequisites > 1 then
				CharManagerMothership.outputUserMessage("char_error_missingskillprerequisite_plural", sName, sPrerequisites);
			else
				CharManagerMothership.outputUserMessage("char_error_missingskillprerequisite", sName, sPrerequisites);
			end
			return;
		end
	end
	
	local wSkill = nil;
	for _,w in pairs(getWindows()) do
		if StringManager.trim(w.name.getValue()) == sName then
			wSkill = w;
			break;
		end
	end
	if not wSkill then
		wSkill = createWindow();
		wSkill.name.setValue(sName);
		wSkill.stat.setStringValue(DB.getValue(nodeSource, "stat", ""):lower());
		-- wSkill.bonus.setValue(DB.getValue(nodeSource, "bonus"));
		wSkill.bonus.setValue(DataCommon.rank_bonus[DB.getValue(nodeSource, "rank"):lower()]);
		--wSkill.setCustom(true);
	end
	-- if wSkill then
		-- DB.setValue(wSkill.getDatabaseNode(), "text", "formattedtext", DB.getValue(nodeSource, "text", ""));
		-- DB.setValue(wSkill.getDatabaseNode(), "rank", "string", DB.getValue(nodeSource, "rank", ""));
		-- DB.setValue(wSkill.getDatabaseNode(), "prerequisites", "string", DB.getValue(nodeSource, "prerequisites", ""));
		-- DB.setValue(wSkill.getDatabaseNode(), "locked", "number", 1);
	-- end
end

function getSalary(nodeChar)
	local nSalary = 0;
	for _,v in pairs(DB.getChildren(nodeChar, "skilllist")) do
		local nBonus = DB.getValue(v, "bonus", "");
		if nBonus == 10 then
			nSalary = nSalary + 500;
		elseif nBonus == 15 then
			nSalary = nSalary + 1000;
		elseif nBonus == 20 then
			nSalary = nSalary + 2000;
		end
	end
	return nSalary;
end

