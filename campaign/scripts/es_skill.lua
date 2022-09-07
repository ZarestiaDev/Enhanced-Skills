-- Zarestia adds function call and handler check whether skill ranks get adjusted
function onInit()
    CalculateSkills()
    DB.addHandler(DB.getPath(getDatabaseNode(), "classes"), "onChildUpdate", CalculateSkills)
end

-- Zarestia adds closing handler check whether skill ranks get adjusted
function onClose()
	DB.removeHandler(DB.getPath(getDatabaseNode(), "classes"), "onChildUpdate", CalculateSkills)
end

-- Zarestia adds CalculateSkills function
function CalculateSkills()
    local nodeChar = getDatabaseNode();
    local tClasses = DB.getChildren(nodeChar.getChild("classes"));
    local nTotalSkillRanks = 0;

    for _,nodeClass in pairs(tClasses) do
        local nSkillRanks = DB.getValue(nodeClass, "skillranks", 0);
        nTotalSkillRanks = nTotalSkillRanks + nSkillRanks;
    end

    DB.setValue(nodeChar, "es.totalskillranks", "number", nTotalSkillRanks);
end