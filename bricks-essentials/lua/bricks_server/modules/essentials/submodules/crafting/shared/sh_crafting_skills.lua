local playerMeta = FindMetaTable( "Player" )

function playerMeta:GetCraftingSkills()
	return ((SERVER and (self.BRS_CRAFTING_SKILLS or {})) or BRICKS_SERVER.TEMP.CraftingSkills) or {}
end

function BRICKS_SERVER.Func.GetCraftingSkillReqExp( skillKey, level )
	local skillConfig = BRICKS_SERVER.CONFIG.CRAFTING.Skills[skillKey]
	return math.floor( skillConfig.BaseExperience*(skillConfig.ExpMultiplier^(level-2)) )
end

function BRICKS_SERVER.Func.GetCraftingSkillProgress( skillKey, level, experience )
    return experience/BRICKS_SERVER.Func.GetCraftingSkillReqExp( skillKey, level+1 )
end