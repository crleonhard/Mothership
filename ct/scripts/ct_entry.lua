
function onLinkChanged()
	super.onLinkChanged();
	
	if not self.isPC() then
		hideNPCFields();
	end
end

function linkPCFields()
	super.linkPCFields();
	
	local nodeChar = link.getTargetDatabaseNode();
	if nodeChar then
		combat.setVisible(false);
		combat_spacer.setVisible(true);
		instinct.setVisible(false);
		instinct_spacer.setVisible(true);
		armor.setLink(nodeChar.createChild("armorpoints", "number"), true);
		damagereduction.setLink(nodeChar.createChild("damagereduction", "number"), true);
		maxwounds.setLink(nodeChar.createChild("maxwounds", "number"), false);
		wounds.setLink(nodeChar.createChild("wounds", "number"), false);
		health.setLink(nodeChar.createChild("health", "number"), false);
		injury.setLink(nodeChar.createChild("injury", "number"), false);
		initresult.setLink(nodeChar.createChild("initresult", "number"));
		button_section_attacks.setVisible(false);
		button_section_attacks_spacer.setVisible(true);
	end
end

function hideNPCFields()
	local nodeChar = link.getTargetDatabaseNode();
	if nodeChar then
		combat.setVisible(combat.getValue() ~= 0);
		combat_spacer.setVisible(combat.getValue() == 0);
	end
end
