--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

iscustom = true;
sets = {};

--[[ Zarestia adds table for skill synergies ]]
local tSynergy = {
	["Autohypnosis"] = {"Knowledge (psionics)"},
	["Bluff"] = {"Diplomacy", "Intimidate", "Sleight of Hand"},
	["Concentration"] = {"Autohypnosis"},
	["Handle Animal"] = {"Ride", "Wild Empathy"},
	["Jump"] = {"Tumble"},
	["Knowledge (arcana)"] = {"Spellcraft"},
	["Knowledge (history)"] = {"Bardic Knowledge"},
	["Knowledge (nobility and royalty)"] = {"Diplomacy"},
	["Knowledge (psionics)"] = {"Psicraft"},
	["Sense Motive"] = {"Diplomacy"},
	["Survival"] = {"Knowledge (nature)"},
	["Tumble"] = {"Balance", "Jump"}
}
-- Zarestia end

function onInit()
	updateMenu();

	onCheckPenaltyChange();
	onStatUpdate();
	-- Zarestia adds function call and handler check whether skill ranks get adjusted
	CalculateSynergy();
	DB.addHandler("charsheet.*.skilllist.*.ranks", "onUpdate", CalculateSynergy);
	-- Zarestia end
end

-- Zarestia adds closing handler check
function onClose()
	DB.removeHandler("charsheet.*.skilllist.*.ranks", "onUpdate", CalculateSynergy);
end
-- Zarestia end

function updateWindow()
	local sLabel = label.getValue();
	local t = DataCommon.skilldata[sLabel];
	if t then
		setCustom(false);

		if t.sublabeling then
			sublabel.setVisible(true);
		end

		if t.armorcheckmultiplier then
			armorcheckmultiplier.setValue(t.armorcheckmultiplier);
		else
			armorcheckmultiplier.setValue(0);
		end

        -- Zarestia adding trainedonly detection
		if t.trainedonly then
			trainedonly.setVisible(true);
		else
			trainedonly.setVisible(false);
		end
        -- End edit
	else
		setCustom(true);
	end
end

function onSystemChanged(bPFMode)
	total.onSourceUpdate();
end

function onMenuSelection(selection, subselection)
	if selection == 6 and subselection == 7 then
		local node = getDatabaseNode();
		if node then
			node.delete();
		else
			close();
		end
	end
end

function onCheckPenaltyChange()
	if armorcheckmultiplier.getValue() ~= 0 then
		armorwidget.setIcon("char_armorcheck");
	else
		armorwidget.setIcon(nil);
	end
end

function onStatUpdate()
	stat.update(statname.getStringValue());
end

--[[
	Zarestia adds CalculateSynergy function
	This goes through the tSynergy table and sets the needed arguments
	for the SetSynergyValue function
]]
function CalculateSynergy()
	local nodeChar = getDatabaseNode()
	local sSkillName = DB.getValue(nodeChar, "label")
	local sSubSkillName = DB.getValue(nodeChar, "sublabel")

	if sSubSkillName ~= "" then
		sSkillName = sSkillName .. " " .. sSubSkillName
	end

	for k,table in pairs(tSynergy) do
		local sTableSkillName = k

		if sSkillName == sTableSkillName then
			local sRanks = DB.getValue(nodeChar, "ranks")

			Debug.chat("Data", sSkillName, sTableSkillName, sRanks)

			for _,v in pairs(table) do
				local sTableSkillSynergyName = v
				if sRanks >= 5 then
					SetSynergyValue(nodeChar, sSkillName, sTableSkillSynergyName, 2)
					--Debug.console("5")
				else
					SetSynergyValue(nodeChar, sSkillName, sTableSkillSynergyName, 0)
					--Debug.console("0")
				end
			end
		end
	end
end
-- Zarestia end

--[[
	Zarestia adds SetSynergyValue function
	sSkillName = source Skill Name (key of tSynergy)
	skillNameSynergy = Name of the synergized Skill (value of tSynergy)
	nSynergyMod = Mod, either 0 or 2
	Sets a new db node mimicking the tSynergy table. All single mods get added together and set.
]]
function SetSynergyValue(nodeChar, sSkillName, skillNameSynergy, nSynergyMod)
	local rActorSkills = DB.getParent(nodeChar)
	local tActorSkills = DB.getChildren(rActorSkills)

	for _,v in pairs(tActorSkills) do
		local foundSkillName = DB.getValue(v, "label")
		local foundSubSkillName = DB.getValue(v, "sublabel")

		if foundSubSkillName ~= "" and foundSubSkillName ~= nil then
			foundSkillName = foundSkillName .. " " .. foundSubSkillName
		end
		
		if foundSkillName == skillNameSynergy then
			DB.setValue(v, "es." .. sSkillName, "number", nSynergyMod)
			local tES = DB.getChildren(v, "es")
			local totalSynergyMod = 0

			for _,es_value in pairs(tES) do
				local sSynergyMod = es_value.getValue()
				totalSynergyMod = totalSynergyMod + sSynergyMod
			end

			DB.setValue(v, "synergy", "number", totalSynergyMod)
		end
	end
end
-- Zarestia end


-- This function is called to set the entry to non-custom or custom.
-- Custom entries have configurable stats and editable labels.
function setCustom(state)
	iscustom = state;

	if iscustom then
		label.setEnabled(true);
		label.setLine(true);
	else
		label.setEnabled(false);
		label.setLine(false);
	end

	updateMenu();
end

function isCustom()
	return iscustom;
end

function updateMenu()
	resetMenuItems();

	if iscustom then
		registerMenuItem(Interface.getString("list_menu_deleteitem"), "delete", 6);
		registerMenuItem(Interface.getString("list_menu_deleteconfirm"), "delete", 6, 7);
	else
		local sLabel = label.getValue();
		local rSkill = DataCommon.skilldata[sLabel];
		if rSkill and rSkill.sublabeling then
			registerMenuItem(Interface.getString("list_menu_deleteitem"), "delete", 6);
			registerMenuItem(Interface.getString("list_menu_deleteconfirm"), "delete", 6, 7);
		end
	end
end
