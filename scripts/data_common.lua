-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

stats = {
	"strength",
	"speed",
	"intellect",
	"combat",
	"instinct"
};

saves = {
	"sanity",
	"fear",
	"body",
	"loyalty"
};

saves_display = {
	["sanity"] = "Sanity",
	["fear"] = "Fear",
	["body"] = "Body",
	["loyalty"] = "Loyalty"
};

maxstress = 20;

-- classes = {
	-- "android",
	-- "marine",
	-- "scientist",
	-- "teamster",
-- };

-- skill_ranktobonus = {
	-- ["trained"] = 10,
	-- ["expert"] = 15,
	-- ["master"] = 20,
-- };

check_result = {
	["critical success"] = 4,
	["success"] = 3,
	["failure"] = 2,
	["critical failure"] = 1,
};

crit_woundtable = {
	["Bleeding"] = "Bleeding Wound",
	-- ["Bleeding and Gore"] = "Bleeding Wound",
	-- ["Bleeding or Gore"] = "Bleeding Wound",
	["Blunt Force"] = "Blunt Force Wound",
	["Fire/Explosives"] = "Fire & Explosives Wound",
	["Gore"] = "Gore & Massive Wound",
	["Gunshot"] = "Gunshot Wound"
}

rank_bonus = {
	["trained"] = 10,
	["expert"] = 15,
	["master"] = 20,
};

function onInit()

	-- class_nametovalue = {
		-- [Interface.getString("class_value_android")] = "android",
		-- [Interface.getString("class_value_marine")] = "marine",
		-- [Interface.getString("class_value_scientist")] = "scientist",
		-- [Interface.getString("class_value_teamster")] = "teamster",
	-- };

	-- class_valuetoname = {
		-- ["android"] = Interface.getString("class_value_android"),
		-- ["marine"] = Interface.getString("class_value_marine"),
		-- ["scientist"] = Interface.getString("class_value_scientist"),
		-- ["teamster"] = Interface.getString("class_value_teamster"),
	-- };
		
end

