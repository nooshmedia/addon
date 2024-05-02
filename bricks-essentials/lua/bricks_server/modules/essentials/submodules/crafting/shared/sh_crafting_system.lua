function BRICKS_SERVER.Func.HasResources( inventory, resources )
	local hasResources = true
	
	local resourceCount = {}
	for k, v in pairs( inventory ) do
		if( v[2] and v[2][1] and v[2][1] == "bricks_server_resource" and resources[v[2][3]] ) then
			resourceCount[v[2][3]] = (resourceCount[v[2][3]] or 0)+v[1]
		end
	end

	for k, v in pairs( resources ) do
		if( not resourceCount[k] or resourceCount[k] < v ) then
			hasResources = false
			break
		end
	end

	return hasResources
end

function BRICKS_SERVER.LoadEntities()
	for k, v in pairs( BRICKS_SERVER.CONFIG.CRAFTING.Resources ) do
		local ENT = {}
		ENT.Type = "anim"
		ENT.Base = "bricks_server_resource"
		
		ENT.PrintName = k
		ENT.Category		= "Bricks Server"
		ENT.Author			= "Brick Wall"
		
		ENT.Spawnable = true
		ENT.AdminSpawnable = true
		
		ENT.ResourceType = k

		scripted_ents.Register( ENT, "bricks_server_resource_" .. string.Replace( string.lower( k ), " ", "" ) )
	end
end

if( BRICKS_SERVER.CONFIG_LOADED ) then
	BRICKS_SERVER.LoadEntities()
else
	hook.Add( "BRS.Hooks.ConfigLoad", "BRS.BRS_ConfigLoad.LoadCraftingEntities", BRICKS_SERVER.LoadEntities )
end