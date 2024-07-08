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
	
	WindowManager.callSafeControlUpdate(self, "installedupgrades", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "maxupgrades", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "upgrades", bReadOnly)
	
	WindowManager.callSafeControlUpdate(self, "minorrepairs", bReadOnly)
	WindowManager.callSafeControlUpdate(self, "majorrepairs", bReadOnly)
	
	WindowManager.callSafeControlUpdate(self, "cargo", bReadOnly)
end
