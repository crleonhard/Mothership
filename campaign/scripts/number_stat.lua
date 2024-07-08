-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function update(bReadOnly, bForceHide)
	setReadOnly(bReadOnly);
	setVisible(not bForceHide);

	local sLabel = getName() .. "_label";
	if window[sLabel] then
		window[sLabel].setVisible(not bForceHide);
	end
	
	if self.onUpdate then
		self.onUpdate(not bForceHide);
	end	
end

function action(draginfo)
	-- local rActor = ActorManager.getActor("", window.getDatabaseNode());
	local rActor = ActorManager.resolveActor(window.getDatabaseNode());
	
	-- local sType = "";
	-- if StringManager.contains(DataCommon.stats, getName()) then
		-- sType = StringManager.capitalize(getName()) .. " check";
	-- elseif StringManager.contains(DataCommon.saves, getName()) then
		-- sType = DataCommon.saves_display[getName()] .. " save";
	-- end
	
	-- MothershipRoller.performAction(draginfo, rActor, getDatabaseNode().getValue() .. " " .. sType);
	local rAction = CharManagerMothership.buildCheckAction(rActor, getName(), getDatabaseNode().getValue());
	ActionCheck.performRoll(draginfo, rActor, rAction);
	return true;
end

function onDragStart(button, x, y, draginfo)
	if rollable then
		return action(draginfo);
	end
end
	
function onDoubleClick(x, y)
	if rollable then
		return action();
	end
end
