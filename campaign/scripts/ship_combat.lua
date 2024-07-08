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

	WindowManager.callSafeControlUpdate(self, "hullpoints", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "mdmg", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "mdmgeffects", bReadOnly)

	WindowManager.callSafeControlUpdate(self, "megadamage", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "installedhardpoints", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "maxhardpoints", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "weapons", bReadOnly)
end
