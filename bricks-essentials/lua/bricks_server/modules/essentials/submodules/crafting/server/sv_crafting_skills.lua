local playerMeta = FindMetaTable( "Player" )

util.AddNetworkString( "BRS.Net.SendCraftingSkills" )
function playerMeta:SendCraftingSkills( ... )
    local skillKeys = { ... }
    local skillsTable = self:GetCraftingSkills()

    net.Start( "BRS.Net.SendCraftingSkills" )
        net.WriteUInt( #skillKeys, 2 )
        for k, v in ipairs( skillKeys ) do
            local skillInfo = skillsTable[v]
            net.WriteString( v )
            net.WriteUInt( skillInfo[1] or 1, 8 )
            net.WriteUInt( skillInfo[2] or 0, 32 )
        end
    net.Send( self )
end

function playerMeta:SetCraftingSkills( skillsTable )
	self.BRS_CRAFTING_SKILLS = skillsTable
end

function playerMeta:AddCraftingSkillExp( skillKey, experience )
	local skillsTable = self:GetCraftingSkills()
    local skillInfo = skillsTable[skillKey] or {}

    local newLevel, newExperience = skillInfo[1] or 1, (skillInfo[2] or 0)+experience
    while( BRICKS_SERVER.Func.GetCraftingSkillProgress( skillKey, newLevel, newExperience ) >= 1 ) do
        newExperience = newExperience-BRICKS_SERVER.Func.GetCraftingSkillReqExp( skillKey, newLevel+1 )
        newLevel = newLevel+1
    end

    skillsTable[skillKey] = { newLevel, newExperience }
    self.BRS_CRAFTING_SKILLS = skillsTable

    self:SendCraftingSkills( skillKey )
end