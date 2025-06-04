-- Zarestia adds function call and handler check whether skill ranks get adjusted
function onInit()
    CalculateSkills()
    DB.addHandler(DB.getPath(getDatabaseNode(), "classes"), "onChildUpdate", CalculateSkills)
    self.onLockModeChanged(WindowManager.getWindowReadOnlyState(self));
end

-- Zarestia adds closing handler check whether skill ranks get adjusted
function onClose()
	DB.removeHandler(DB.getPath(getDatabaseNode(), "classes"), "onChildUpdate", CalculateSkills)
end

-- Zarestia adds CalculateSkills function
function CalculateSkills()
    local nodeChar = getDatabaseNode();
    local nTotalSkillRanks = 0;

    for _,nodeClass in pairs(DB.getChildList(DB.getChild(nodeChar, "classes"))) do
        local nSkillRanks = DB.getValue(nodeClass, "skillranks", 0);
        nTotalSkillRanks = nTotalSkillRanks + nSkillRanks;
    end

    DB.setValue(nodeChar, "es.totalskillranks", "number", nTotalSkillRanks);
end

function onLockModeChanged(bReadOnly)
    local tFields = { "skills_iadd_profession", "skills_iadd_perform", "skills_iadd_knowledge", "skills_iadd_craft", "skills_iadd", };
    WindowManager.callSafeControlsSetLockMode(self, tFields, bReadOnly);
end