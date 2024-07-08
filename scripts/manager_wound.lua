function getWoundResults(sCrit)
	local bCritADV = string.match(sCrit, "%[%+%]");
	local bCritDIS = string.match(sCrit, "%[%-%]");
	local aTables = { DataCommon.crit_woundtable[sCrit:gsub("%s*%[[%+%-]%]", "")] };

	if sCrit:match("Bleeding%s*%[%+%] or Gore%s*%[%+%]") then
		--aTables = { { DataCommon.crit_woundtable["Bleeding"], DataCommon.crit_woundtable["Gore"] }[math.random(2)] };
		if math.random(2) == 1 then
			aTables = { DataCommon.crit_woundtable["Bleeding"]};
		else
			aTables = { DataCommon.crit_woundtable["Gore"] };
		end
	elseif sCrit:match("Bleeding and Gore") then
		aTables = { DataCommon.crit_woundtable["Bleeding"], DataCommon.crit_woundtable["Gore"] };
	end

	local aAllResults = { };
	for _,sTable in pairs(aTables) do
		local nodeTable = TableManager.findTable(sTable);
		if not nodeTable then
			Debug.console(Interface.getString("table_error_lookupfail") .. " (" .. sTable .. ")");
		end
		local nTotal = math.random(10) - 1;
		if bCritADV then
			nTotal = math.max(nTotal, math.random(10) - 1);
		elseif bCritDIS then
			nTotal = math.min(nTotal, math.random(10) - 1);
		end
		
		table.insert(aAllResults, TableManager.getResults(nodeTable, nTotal, 0));
	end
		
	return aAllResults;
end

-- function onWoundOptionSelect(aSelection, rOption)
	-- if #aSelection > 0 then
		-- local sStat = aSelection[1]:lower();
		-- DB.setValue(rOption.nodeChar, "stats." .. sStat, "number", DB.getValue(rOption.nodeChar, "stats." .. sStat, 0) + rOption.custom);
	-- end
-- end
