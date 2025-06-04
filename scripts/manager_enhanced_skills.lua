--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local tSynergy = {
	["autohypnosis"] = {"knowledge (psionics)"},
	["bluff"] = {"diplomacy", "intimidate", "sleight of hand"},
	["concentration"] = {"autohypnosis"},
	["handle animal"] = {"ride", "wild empathy"},
	["jump"] = {"tumble"},
	["knowledge (arcana)"] = {"spellcraft"},
	["knowledge (history)"] = {"bardic knowledge"},
	["knowledge (nobility and royalty)"] = {"diplomacy"},
	["knowledge (psionics)"] = {"psicraft"},
	["sense motive"] = {"diplomacy"},
	["survival"] = {"knowledge (nature)"},
	["tumble"] = {"balance", "jump"}
};

--This goes through the tSynergy table and sets the needed arguments for the SetSynergyValue function
function SetSynergy(nodeChar)
	local sSkillName = DB.getValue(nodeChar, "label", ""):lower();
	local sSubSkillName = DB.getValue(nodeChar, "sublabel", ""):lower();

	if sSubSkillName ~= "" then
		sSkillName = sSkillName .. " " .. sSubSkillName;
	end

	for sSourceSkill,_ in pairs(tSynergy) do
		if sSkillName == sSourceSkill then
			local nRanks = DB.getValue(nodeChar, "ranks");

			if nRanks >= 5 then
				SetSynergyValue(nodeChar, sSourceSkill, 2);
			else
				SetSynergyValue(nodeChar, sSourceSkill, 0);
			end
		end
	end
end

function SetSynergyValue(nodeChar, sSourceSkill, nSynergyMod)
	for _,sSynergy in ipairs(tSynergy[sSourceSkill]) do
		for _,nodeSkill in ipairs(DB.getChildList(DB.getParent(nodeChar))) do
			local sSkillName = DB.getValue(nodeSkill, "label", ""):lower();
			local sSubSkillName = DB.getValue(nodeSkill, "sublabel", ""):lower();

			if sSubSkillName ~= "" then
				sSkillName = sSkillName .. " " .. sSubSkillName;
			end

			if sSkillName == sSynergy then
				DB.setValue(nodeSkill, "es." .. sSourceSkill, "number", nSynergyMod);
				
				CalculateSynergy(nodeSkill);
			end
		end
	end
end

function CalculateSynergy(nodeSkill)
	local totalSynergyMod = 0;

	for _,nodeES in ipairs(DB.getChildList(nodeSkill, "es")) do
		totalSynergyMod = totalSynergyMod + DB.getValue(nodeES, "", 0);
	end

	DB.setValue(nodeSkill, "synergy", "number", totalSynergyMod);
end

function RecalculateSkills(nodeChar)
    local nBase = DB.getValue(nodeChar, "es.baseskillranks", 0);
    local nFeat = DB.getValue(nodeChar, "es.featskillranks", 0);
    local nMisc = DB.getValue(nodeChar, "es.miscskillranks", 0);

    local nTotal = nBase + nFeat + nMisc;
    DB.setValue(nodeChar, "es.totalskillranks", "number", nTotal);
end
