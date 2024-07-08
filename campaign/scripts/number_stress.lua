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
	ActionPanic.performRoll(draginfo, rActor);
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
