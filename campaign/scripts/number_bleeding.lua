-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function update(bReadOnly)
	setReadOnly(bReadOnly);
end

function action(draginfo)
	-- local rActor = ActorManager.getActor("", window.getDatabaseNode());
	local rActor = ActorManager.resolveActor(window.getDatabaseNode());
	local rAction = buildBleedingDamageAction(getValue());
	local rRoll = ActionDamage.getRoll(rSource, rAction);
	ActionDamage.onDamage(rActor, rActor, rRoll);
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

function buildBleedingDamageAction(nDamage)
	local rAction = {};
	rAction.label = "Bleeding";
	rAction.damage = nDamage .. " DMG";
	rAction.sCrit = "Bleeding";
	rAction.bIsBleed = true;
	return rAction;
end
