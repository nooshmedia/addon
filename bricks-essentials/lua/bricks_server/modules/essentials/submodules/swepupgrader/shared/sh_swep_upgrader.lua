local weaponMeta = FindMetaTable( "Weapon" )

function weaponMeta:BRS_GetVariableValue( variable )
	if( self.Primary and self.Primary[variable] ) then
		return self.Primary[variable]
	else
		return self[variable]
	end
end