-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- Ruleset action types
actions = {
	["dice"] = { bUseModStack = true },
	["table"] = { },
	["attack"] = { sIcon = "action_attack", sTargeting = "each", bUseModStack = true },
	["damage"] = { sIcon = "action_damage", sTargeting = "all", bUseModStack = true },
	["msdamage"] = { sIcon = "action_damage", sTargeting = "all", bUseModStack = true },
	-- ["msdamage10"] = { sIcon = "action_damage", sTargeting = "all", bUseModStack = true },
	-- ["heal"] = { sIcon = "action_heal", sTargeting = "all", bUseModStack = true },
	-- ["effect"] = { sIcon = "action_effect", sTargeting = "all" },
	-- ["init"] = { bUseModStack = true },
	["check"] = { bUseModStack = true },
	["save"] = { bUseModStack = true },
	-- ["death"] = { bUseModStack = true },
	["rest"] = { bUseModStack = true },
	["stress"] = { bUseModStack = true },
	-- ["recovery"] = { bUseModStack = true },
};

targetactions = {
	"attack",
	"damage",
	"msdamage",
	-- "msdamage10",
	-- "heal",
	-- "effect"
};

currencies = { "cr", "kcr", "mcr", "bcr" };
currencyDefault = "cr";

-- function onInit()	
	-- ActionsManager.useFGUDiceValues(true);
-- end

function getCharSelectDetailHost(nodeChar)
	return DB.getValue(nodeChar, "pcclass", "");
end

function requestCharSelectDetailClient()
	return "name,pcclass";
end

function receiveCharSelectDetailClient(vDetails)
	return vDetails[1], vDetails[2];
end

function getCharSelectDetailLocal(nodeLocal)
	return DB.getValue(nodeLocal, "name", ""), "FOO";
end

function getDistanceUnitsPerGrid()
	return 1;
end
