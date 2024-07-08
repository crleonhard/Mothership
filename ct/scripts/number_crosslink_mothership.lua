-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local bLocked = false;
local sLink = nil;

function onInit()
	if super and super.onInit then
		super.onInit();
	end

	if self.update then
		self.update();
	end
end

function onClose()
	if sLink then
		DB.removeHandler(sLink, "onUpdate", onLinkUpdated);
	end
end

function onDrop(x, y, draginfo)
	if User.isHost() then
		if draginfo.getType() ~= "number" then
			return false;
		end

		if self.handleDrop then
			self.handleDrop(draginfo);
			return true;
		end
	end
end

function onValueChanged()
	if sLink then
		if not bLocked then
			bLocked = true;

			if sLink and not isReadOnly() then
				DB.setValue(sLink, "number", getValue());
			end

			if self.update then
				self.update();
			end

			bLocked = false;
		end
	else
		if self.update then
			self.update();
		end
	end
end

function onLinkUpdated()
	if sLink and not bLocked then
		bLocked = true;

		setValue(DB.getValue(sLink, 0));
		
		if self.update then
			self.update();
		end

		bLocked = false;
	end
end

function setLink(dbnode, bLock)
	if sLink then
		DB.removeHandler(sLink, "onUpdate", onLinkUpdated);
		sLink = nil;
	end
		
	if dbnode then
		sLink = dbnode.getNodeName();

		-- if not nolinkwidget then
			-- addBitmapWidget("field_linked").setPosition("bottomright", 0, -2);
		-- end
		
		if bLock == true then
			setReadOnly(true);
		end

		DB.addHandler(sLink, "onUpdate", onLinkUpdated);
		onLinkUpdated();
	end

	function action(draginfo)
		-- local rActor = ActorManager.getActorFromCT(window.getDatabaseNode());
		local rActor = ActorManager.resolveActor(window.getDatabaseNode());
		-- local sType = "";
		-- if StringManager.contains(DataCommon.stats, getName()) then
			-- sType = StringManager.capitalize(getName()) .. " check";
		-- elseif StringManager.contains(DataCommon.saves, getName()) then
			-- sType = DataCommon.saves_display[getName()] .. " save";
		-- end
		
		-- MothershipRoller.performAction(draginfo, rActor, getValue() .. " " .. sType);
		-- if draginfo then
			-- local rAction = { label = "Combat check", nRollUnder = getValue() };
			-- ActionAttack.performRoll(draginfo, rActor, rAction);
		-- else
			local rAction = CharManagerMothership.buildCheckAction(rActor, getName(), getValue());		
			ActionCheck.performRoll(draginfo, rActor, rAction);
		-- end

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

end

