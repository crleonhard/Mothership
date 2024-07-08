
function getPercentWounded(rActor)
	local _, nodeActor = ActorManager.getTypeAndNode(rActor);
	local nMaxWounds = math.max(DB.getValue(nodeActor, "maxwounds", 0), 0);
	local nWounds = math.max(DB.getValue(nodeActor, "wounds", 0), 0);
	local nHealth = math.max(DB.getValue(nodeActor, "health", 0), 0);
	local nInjury = math.max(DB.getValue(nodeActor, "injury", 0), 0);

	local nPercentWounded = 0;
	if nMaxWounds * math.max(nHealth, 1) > 0 then
		nPercentWounded = ((nWounds * math.max(nHealth, 1)) + nInjury) / (nMaxWounds * math.max(nHealth, 1));
	end
	
	local sStatus;
	if nPercentWounded >= 1 then
		sStatus = "Down";
	else
		if nPercentWounded >= .5 then
			sStatus = "Heavily Wounded";
		elseif nWounds > 0 then
			sStatus = "Wounded";
		elseif nInjury > 0 then
			sStatus = "Injured";
		else
			sStatus = "Healthy";
		end
	end
	
	return nPercentWounded, sStatus;
end
