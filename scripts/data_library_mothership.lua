-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function getItemRecordDisplayClass(vNode)
	local sRecordDisplayClass = "item";
	if vNode then
		local sBasePath, sSecondPath = UtilityManager.getDataBaseNodePathSplit(vNode);
		if sBasePath == "reference" then
			local sTypeLower = StringManager.trim(DB.getValue(DB.getPath(vNode, "type"), ""):lower());
			if sTypeLower == "weapon" then
				sRecordDisplayClass = "reference_weapon";
			elseif sTypeLower == "armor" then
				sRecordDisplayClass = "reference_armor";
			elseif sTypeLower == "loadout" then
				sRecordDisplayClass = "reference_loadout";
			else
				sRecordDisplayClass = "reference_equipment";
			end
		end
	end
	return sRecordDisplayClass;
end

aListViews = {
	["item"] = {
		["equipment"] = {
			-- sTitleRes = "item_grouped_title_equipment",
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "item_grouped_label_name", nWidth=150 },
				{ sName = "cost", sType = "string", sHeadingRes = "item_grouped_label_cost", bCentered=true },
			},
			aFilters = { 
				{ sDBField = "type", vFilterValue = "Equipment" }
			},
			aGroups = { },
		},
		["loadout"] = {
			-- sTitleRes = "item_grouped_title_loadouts",
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "item_grouped_label_name", nWidth=150 },
			},
			aFilters = { 
				{ sDBField = "type", vFilterValue = "Loadout" }
			},
			aGroups = { },
		},
		["armor"] = {
			-- sTitleRes = "item_grouped_title_armor",
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "item_grouped_label_name", nWidth=150 },
				{ sName = "cost", sType = "string", sHeadingRes = "item_grouped_label_cost", bCentered=true },
				{ sName = "armorpoints", sType = "number", sHeadingRes = "item_grouped_label_armor", bDisplaySign=false, nWidth=40, bCentered=true, nSortOrder=1 },
				{ sName = "damagereduction", sType = "number", sHeadingRes = "item_grouped_label_damagereduction", bDisplaySign=false, nWidth=40, bCentered=true }
			},
			aFilters = { 
				{ sDBField = "type", vFilterValue = "Armor" }
			},
			aGroups = { },
		},
		["weapon"] = {
			-- sTitleRes = "item_grouped_title_weapons",
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "item_grouped_label_name", nWidth=150 },
				{ sName = "cost", sType = "string", sHeadingRes = "item_grouped_label_cost", bCentered=true },
				{ sName = "damage", sType = "string", sHeadingRes = "item_grouped_label_damage", nWidth=150, bCentered=true },
			},
			aFilters = { 
				{ sDBField = "type", vFilterValue = "Weapon" }
			},
			aGroups = { },
		},
	},
	-- ["ship"] = {
		-- ["bytype"] = {
			-- aColumns = {
				-- { sName = "name", sType = "string", sHeadingRes = "vehicle_grouped_label_name", nWidth=200 },
				-- { sName = "cost", sType = "string", sHeadingRes = "vehicle_grouped_label_cost", nWidth=80, bCentered=true },
				-- { sName = "speed", sType = "string", sHeadingRes = "vehicle_grouped_label_speed", sTooltipRes="vehicle_grouped_tooltip_speed", nWidth=200, bWrapped=true },
			-- },
			-- aFilters = {},
			-- aGroups = { { sDBField = "type" } },
			-- aGroupValueOrder = {},
		-- },
	-- },
	["skill"] = {
		["byrank"] = {
			-- sTitleRes = "skill_grouped_title_byrank",
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "skill_grouped_label_name", nWidth=120 },
				{ sName = "rank", sType = "string", sHeadingRes = "skill_grouped_label_rank", bCentered=true},
				{ sName = "prerequisites", sType = "string", sHeadingRes = "skill_grouped_label_prerequisites", sTooltipRes="skill_grouped_tooltip_prerequisites", nWidth=400 },
			},
			aFilters = {},
			aGroups = { { sDBField = "rank" } },
			aGroupValueOrder = { "Trained", "Expert", "Master" },
		},
	},
};

aRecordOverrides = {
	-- MoreCore overrides
	["npc"] = { 
		bID = false,
		aDataMap = { "npc", "reference.npcdata" }, 
		-- sListDisplayClass = "masterindexitem_id",
		-- sRecordDisplayClass = "npc", 
		aGMEditButtons = { },
	},
	["item"] = {
		bID = false,
		-- fIsIdentifiable = isItemIdentifiable,
		-- aDataMap = { "item", "reference.equipmentdata", "reference.magicitemdata" }, 
		aDataMap = { "item", "reference.equipmentdata" }, 
		fRecordDisplayClass = getItemRecordDisplayClass,
		-- aRecordDisplayClasses = { "item", "reference_magicitem", "reference_armor", "reference_weapon", "reference_equipment", "reference_mountsandotheranimals", "reference_waterbornevehicles", "reference_vehicle" },
		aRecordDisplayClasses = { "item", "reference_armor", "reference_weapon", "reference_equipment", "reference_loadout" },
		-- aGMListButtons = { "button_item_armor", "button_item_weapons", "button_item_templates", "button_forge_item" },
		aGMListButtons = { "button_item_armor", "button_item_weapons", "button_item_equipment", "button_item_loadouts" };
		-- aPlayerListButtons = { "button_item_armor", "button_item_weapons" },
		aPlayerListButtons = { "button_item_armor", "button_item_weapons", "button_item_equipment" };
		aCustomFilters = {
			["Type"] = { sField = "type" },
			-- ["Rarity"] = { sField = "rarity", fGetValue = getItemRarityValue },
			-- ["Attunement?"] = { sField = "rarity", fGetValue = getItemAttunementValue },
		},
	},
	["ability"] = { bHidden = true },
	["pcclass"] = {
		bExport = true, 
		-- aDataMap = { "pcclass", "reference.pcclass" }, 
		aDataMap = { "pcclass", "reference.classdata" }, 
		sRecordDisplayClass = "pcclass", 
		sSidebarCategory = "player",
	},
	["pcrace"] = { bHidden = true },
	["cas"] = { bHidden = true },
	-- CoreRPG overrides
	["vehicle"] = { bHidden = true },
	-- New record types
	["ship"] = { 
		bExport = true,
		-- bID = true,
		aDataMap = { "ship", "reference.shipdata" }, 
		sRecordDisplayClass = "ship", 
	},
	["skill"] = {
		bExport = true, 
		aDataMap = { "skill", "reference.skilldata" }, 
		-- aDisplayIcon = { "button_skills", "button_skills_down" },
		sRecordDisplayClass = "reference_skill", 
		aGMListButtons = { "button_skill_reference" };
		aPlayerListButtons = { "button_skill_reference" };
		sSidebarCategory = "player",
	},
};

-- aDefaultSidebarState = {
	-- ["gm"] = "charsheet,npc,table,battle,image,treasureparcel,item,note,story",
	-- ["play"] = "charsheet,table,item,note",
	-- ["create"] = "charsheet,table,pcclass,skill,item,note",
-- };

function onInit()

	-- for kDefSidebar,vDefSidebar in pairs(aDefaultSidebarState) do
		-- DesktopManager.setDefaultSidebarState(kDefSidebar, vDefSidebar);
	-- end
	for kRecordType,vRecordType in pairs(aRecordOverrides) do
		LibraryData.overrideRecordTypeInfo(kRecordType, vRecordType);
	end
	for kRecordType,vRecordListViews in pairs(aListViews) do
		for kListView, vListView in pairs(vRecordListViews) do
			LibraryData.setListView(kRecordType, kListView, vListView);
		end
	end
	
end
