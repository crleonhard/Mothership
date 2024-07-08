-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	super.onInit();

	local sPath = DB.getPath(getDatabaseNode()) .. ".pcclass";
	DB.addHandler(sPath, "onUpdate", updateDetails);
end

function onClose()
	super.onClose();
	
	local sPath = DB.getPath(getDatabaseNode()) .. ".pcclass";
	DB.removeHandler(sPath, "onUpdate", updateDetails);
end

function updateDetails(nodeClass)
	local sDetails = DB.getValue(nodeClass, "");
	details.setValue(sDetails);
end
