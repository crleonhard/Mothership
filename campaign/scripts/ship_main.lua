-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	update();
end
function VisDataCleared()
	update();
end
function InvisDataAdded()
	update();
end

function update()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);

	-- local bSection1 = false;
	-- divider.setVisible(bSection1);
	
	WindowManager.callSafeControlUpdate(self, "classification", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "captain", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "crew", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "maxcrew", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "transponder", bReadOnly)

	WindowManager.callSafeControlUpdate(self, "thrusters", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "battle", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "systems", bReadOnly)
	
	WindowManager.callSafeControlUpdate(self, "fuel", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "maxfuel", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "o2", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "warpcores", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "cryopods", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "escapepods", bReadOnly)

	-- local bSection2 = false;
	-- if WindowManager.callSafeControlUpdate(self, "type", bReadOnly) then bSection2 = true; end;
	-- divider2.setVisible(bSection2);

	-- WindowManager.callSafeControlUpdate(self, "cost", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "weight", bReadOnly);
	-- WindowManager.callSafeControlUpdate(self, "speed", bReadOnly);
end
