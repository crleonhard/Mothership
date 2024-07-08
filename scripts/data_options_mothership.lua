-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	registerOptions();
end

function registerOptions()
	OptionsManager.registerOption2("HRARM", false, "option_header_houserule", "option_label_HRARM", "option_entry_cycler", 
			{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" });
	OptionsManager.registerOption2("HREFF", false, "option_header_houserule", "option_label_HREFF", "option_entry_cycler", 
			{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	OptionsManager.registerOption2("HRLOA", false, "option_header_houserule", "option_label_HRLOA", "option_entry_cycler", 
			{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	OptionsManager.registerOption2("HRPAN", false, "option_header_houserule", "option_label_HRPAN", "option_entry_cycler", 
			{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	OptionsManager.registerOption2("HRSTO", false, "option_header_houserule", "option_label_HRSTO", "option_entry_cycler", 
			{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	OptionsManager.registerOption2("HRSTR", false, "option_header_houserule", "option_label_HRSTR", "option_entry_cycler", 
			{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "on" });
	OptionsManager.registerOption2("HRTRI", false, "option_header_houserule", "option_label_HRTRI", "option_entry_cycler", 
			{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	OptionsManager.registerOption2("HRWND", false, "option_header_houserule", "option_label_HRWND", "option_entry_cycler", 
			{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });

	-- OptionsManager.addOptionValue("DDCL", "option_val_DDCL_morecore", "desktopdecal_mothership", true);
	-- OptionsManager.setOptionDefault("DDCL", "desktopdecal_mothership");
	
	OptionsManager.deleteOption("HRDD");
	OptionsManager.deleteOption("MCC2");
	OptionsManager.deleteOption("MCC2C");
	OptionsManager.deleteOption("MCC4");
	OptionsManager.deleteOption("MCC4C");
	OptionsManager.deleteOption("MCC5");
	OptionsManager.deleteOption("MCC5C");
	OptionsManager.deleteOption("MCInitDice");
end
