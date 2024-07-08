# Mothership Ruleset for Fantasy Grounds

## Reference Data
* Make sure that all classes and skill are **shared with players**, as well as any items they need access to (especially loadouts and items contained in loadouts)

### Classes
* Stats, Saves, Max Wounds (=2+bonus), Trauma Response, Skills: copy from MS character sheet
* enter class skills exactly as they appear on the character sheet, adding a period after the last skill to seperate them from bonus skills

### Skills
* Rank: as indicated on MS character sheet
* Default Stat: choose the default stat for skill rolls with this skill
* Prerequisites: comma-separated list of any prerequisite skills for this skill, e.g. "Military Training, Rimwise"

### Items
* Type: Weapon/Armor/Equipment/Loadouts
* all fields should be copied directly from the PSG weapon/armor/equipment tables
* for loadouts, drag and drop the desired items into the Items list on the loadout
* Weapon.Damage: for the Rigging Gun, just put the base damage here and add the "when removed" damage to the Special description
* Armor.DR: any damage reduction mentioned under Special should be entered here

### NPCs
* used for monsters, contractors, and pets
* Rnd Instinct is for pets and will populate Instinct when added to the Combat Tracker
* Rnd Loyalty is for contractors and will populate Loyalty when added to the Combat Tracker

### Ships
* all fields should be copied directly from the SBT ship manifest
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
* These tables must be created and **shared with players** to enable the corresponding house rules above
	* (Android/Marine/Scientist/Teamster) Loadouts
	* Trinkets
	* Patches
	* Panic Effect
	* (Bleeding/Blunt Force/Fire & Explosives/Gore & Massive/Gunshot) Wound
		* 2 columns (1=severity, 2=description)

## Usage

### Character Sheet

#### Main
* Class: drag-and-drop from the Classes list
	* If your Classes and Skills have been populated properly, adding a class will prompt the player for any skill selections and autopopulate everything on the Main and Skills tabs
* Stats/Saves: double-click to roll a check/save
* Stress: double-click to roll a Panic Check
* Rest: double-click to roll a Rest Save
* Bleeding: double-click to apply Bleeding damage
* Weapons panel: Weapons added to inventory will appear here. Double-click the die roll button to roll an attack. The scripting takes a best guess at any skill bonuses that should apply to that weapon, but you can click the skill bonus button next to the die roll to cycle to a different bonus if desired. Double-click the damage button to roll damage.

#### Skills
* Click on STAT to cycle through stats and select which one to roll, then double-click TOTAL to roll the check 
* (If you want to apply a skill to a save, just add the bonus to the modifier box and roll on the Main tab)

#### Inventory
* Drag-and-drop from the Items list.
* AP and DR for equipped armor will automatically be applied to incoming damage rolls. (To bypass armor, either unequip temporarily or roll damage without targeting and apply manually.)
* Weapons will automatically be added to the Weapons list on the MAIN tab.
* Credits are tracked at the bottom of this tab.

####Notes
* In addition to notes fields, this tab also provides a list where you can add/remove conditions

### Combat Tracker
* Com =Combat, Ins =Instinct: for NPCs, double-click to roll
* Arm =Armor, DR
* MW =Max Wounds, Wnds =Wounds: max wounds, wounds taken
* Hlth =Health, Inj =Injury: max health, health lost
* X: visual indicator of damage
* Init: initiative order if Strict Turn Order house rule enabled
* attacks and damage rolls can be dragged onto targets in CT; if the corresponding house rules are enabled, wounds and panic checks will applied to the target as appropriate

### Rolls

#### Modifier Buttons
* SAFE is for situations where you might want to let someone roll without risk of stress/panic
* The -5/-10/-25 modifiers are for rolling damage when the target is behind insignificant/light/heavy cover
