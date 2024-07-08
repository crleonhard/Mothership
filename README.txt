# Mothership 1e Ruleset for Fantasy Grounds

## Reference Data
* you will need to add class, skill, and item data manually to get much value out of the character sheet
* make sure that all classes and skills are **shared with players**, as well as any items they need access to (e.g. class loadouts and items contained in loadouts)

### Classes
* most fields can be copied directly from the PSG character sheet
* Max Wounds = 2 + class bonus
* Skills: enter class skills exactly as they appear on the character sheet, adding a period after the last one to seperate them from bonus skills (e.g. "Military Training, Athletics. Bonus: 1 Expert Skill OR: 2 Trained Skills")

### Skills
* Rank: as indicated on the PSG character sheet
* Default Stat: choose the default stat for checks made with this skill
* Prerequisites: comma-separated list of any direct prerequisites for this skill as indicated by the chart on the PSG character sheet, e.g. "Military Training, Rimwise" for Firearms

### Items
* all fields can be copied directly from the PSG weapon/armor/equipment/loadout tables
* for loadouts, drag and drop the desired items into the Items list on the loadout
* Weapon.Damage: for the Rigging Gun, just put the base damage here and add the "when removed" damage to the Special description
* Armor.DR: any damage reduction mentioned under Special should be entered here

### NPCs
* used for monsters, contractors, and pets
* Rnd Instinct is for pets and will populate Instinct when added to the CT
* Rnd Loyalty is for contractors and will populate Loyalty when added to the CT

### Ships
* all fields can be copied directly from the SBT ship manifest
* MDMG and MDMG Effects under the Status section correspond to the Megadamage the ship has **taken**
* Megadamage under the Weapons section corresponds to the Megadamage the ship **inflicts**

## House Rules
* Armor Damage [on]: Apply Armor damage
* Loadouts [off]: Automatic equipment loadouts
	* requires "*classname* Loadouts" table for each class
* Panic [off]: Automatic Panic checks
	* requires "Panic Effect" table
* Stress [on]: Apply Stress changes
* Strict Turn Order [off]: Roll Speed checks for initiative
* Trinkets [off]: Automatic trinkets and patches
	* requires "Trinkets" and "Patches" tables
* Wound Effects [off]: Apply Wound and Panic effects
	* requires Wound Rolls and Panic house rules to be enabled
* Wound Rolls [off]: Automatic Wound rolls
	* requires "*woundtype* Wound" table for each wound type

## Tables
* These tables must be created (copied directly from the relevant PSG tables) and **shared with players** to enable the corresponding house rules above
	* (Android/Marine/Scientist/Teamster) Loadouts
	* Trinkets
	* Patches
	* Panic Effect
	* (Bleeding/Blunt Force/Fire & Explosives/Gore & Massive/Gunshot) Wound
		* 2 columns (1=severity, 2=description)

## Functionality

### Character Sheet

#### Main
* Class: drag-and-drop from the Classes list
	* if your Classes and Skills have been populated properly, adding a class will prompt the player for any bonus skill selections and autopopulate everything on the Main and Skills tabs
* Stats/Saves: double-click to roll a check/save
* Stress: double-click to roll a Panic Check
* Rest: double-click to roll a Rest Save
* Bleeding: double-click to apply Bleeding damage
* Weapons panel: weapons added to inventory will appear here automatically
	* the ruleset takes a best guess at any skill bonus that should apply to that weapon, but click the skill bonus to cycle to a different value if desired
	* double-click the die roll button to roll an attack
	* double-click the damage button to roll damage
	* ammo checkboxes toggle automatically each time an attack is rolled with that weapon, but can be manually toggled as well

#### Skills
* click on Stat to cycle through stats and select which one to roll against, then double-click Total to roll the check 
* to apply a skill bonus to a save, just add the bonus to the modifier box and roll on the Main tab normally

#### Inventory
* drag-and-drop from the Items list
	* dropping a loadout will automatically add all items contained in that loadout
* AP and DR for **equipped** armor will automatically be applied to incoming damage rolls
	* to bypass armor completely, either toggle it temporarily to unequipped or just roll damage without targeting and apply damage manually
* weapons will automatically be added to the Weapons list on the Main tab
* credits are tracked at the bottom of this tab

#### Notes
* in addition to notes fields, this tab also provides a list for tracking conditions

### Combat Tracker
* Com =Combat, Ins =Instinct: for NPCs, double-click to roll a check
* Arm =Armor, DR =Damage Reduction
* MW =Max Wounds, Wnds =Wounds: max wounds, wounds taken
* Hlth =Health, Inj =Injury: max health, health lost
* X: visual indicator of damage
* Init: initiative order (if Strict Turn Order house rule enabled)
* damage rolls can be dragged onto targets in CT
	* NPCs have an Attacks dropdown from which damage rolls can be made
	* if the corresponding house rules are enabled, wounds and panic checks resulting from damage will be applied to targets as appropriate

### Rolls
* rollable fields can be double-clicked and are indicated by a die icon

#### Modifier Buttons
* SAFE is for situations where you might want to let someone roll a check without risk of stress/panic
* the -5/-10/-25 modifiers are for rolling damage when the target is behind insignificant/light/heavy cover
