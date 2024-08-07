-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	DB.addHandler(DB.getPath(getDatabaseNode()), "onChildAdded", onChildAdded);
	-- DB.addHandler(DB.getPath(window.getDatabaseNode(), "profbonus"), "onUpdate", onProfChanged);
	
	onModeChanged();
end

function onClose()
	DB.removeHandler(DB.getPath(getDatabaseNode()), "onChildAdded", onChildAdded);
	-- DB.removeHandler(DB.getPath(window.getDatabaseNode(), "profbonus"), "onUpdate", onProfChanged);
end

function onChildAdded()
	onModeChanged();
	update();
end

function onProfChanged()
	for _,w in pairs(getWindows()) do
		w.onAttackChanged();
	end
end

function onListChanged()
	update();
end

function onModeChanged()
	local bPrepMode = (DB.getValue(window.getDatabaseNode(), "powermode", "") == "preparation");
	for _,w in ipairs(getWindows()) do
		w.carried.setVisible(bPrepMode);
	end
	
	applyFilter();
end

function update()
	if window.parentcontrol.window.actions_iedit then
		local bEditMode = (window.parentcontrol.window.actions_iedit.getValue() == 1);
		for _,w in pairs(getWindows()) do
			w.idelete.setVisibility(bEditMode);
		end
	end
end

function addEntry(bFocus)
	local w = createWindow();
	if bFocus and w then
		w.name.setFocus();
	end
	return w;
end

function onDrop(x, y, draginfo)
	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		if LibraryData.isRecordDisplayClass("item", sClass) and ItemManager2.isWeapon(sRecord) then
			return ItemManager.handleAnyDrop(window.getDatabaseNode(), draginfo);
		end
	end
end

function onFilter(w)
	if (DB.getValue(window.getDatabaseNode(), "powermode", "") == "combat") and (w.carried.getValue() < 2) then
		return false;
	end
	return true;
end
