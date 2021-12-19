--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

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
--[[
	This goes through the tSynergy table and sets the needed arguments
	for the SetSynergyValue function
]]
function CalculateSynergy(nodeChar)
	local sSkillName = DB.getValue(nodeChar, "label")
	local sSubSkillName = DB.getValue(nodeChar, "sublabel")

	if sSubSkillName ~= "" then
		sSkillName = sSkillName .. " " .. sSubSkillName
	end

	for k,table in pairs(tSynergy) do
		local sTableSkillName = k

		if sSkillName == sTableSkillName then
			local sRanks = DB.getValue(nodeChar, "ranks")

			for _,v in pairs(table) do
				local sTableSkillSynergyName = v
				if sRanks >= 5 then
					SetSynergyValue(nodeChar, sSkillName, sTableSkillSynergyName, 2)
				else
					SetSynergyValue(nodeChar, sSkillName, sTableSkillSynergyName, 0)
				end
			end
		end
	end
end
--[[
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
            Debug.chat(sSkillName)
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