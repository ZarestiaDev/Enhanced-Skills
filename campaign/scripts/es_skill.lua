-- Zarestia adds function call and handler check whether skill ranks get adjusted
function onInit()
    CalculateSkills()
    DB.addHandler(DB.getPath(getDatabaseNode(), "classes"), "onChildUpdate", CalculateSkills)
end

-- Zarestia adds closing handler check whether skill ranks get adjusted
function onClose()
	DB.removeHandler(DB.getPath(getDatabaseNode(), "classes"), "onChildUpdate", CalculateSkills)
end

--[[ Zarestia adds CalculateSkills function
    This function iterates through all classes of the player character and reads
    the skillranks of every class out. At the end a new db node is set to store the total value.
]]
function CalculateSkills()
    local nodeChar = getDatabaseNode()
    local tClasses = DB.getChildren(nodeChar.getChild("classes"))
    local nTotalSkillRanks = 0

    for _,v in pairs(tClasses) do
        local nSkillRanks = DB.getValue(v, "skillranks", 0)
        nTotalSkillRanks = nTotalSkillRanks + nSkillRanks
    end

    DB.setValue(nodeChar, "es.totalskillranks", "number", nTotalSkillRanks)
end