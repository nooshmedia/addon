util.AddNetworkString( "BRS.Net.UpgradeSWEP" )
net.Receive( "BRS.Net.UpgradeSWEP", function( len, ply ) 
	local weaponClass = net.ReadString()

	if( not weaponClass or BRICKS_SERVER.CONFIG.SWEPUPGRADES.Blacklist[weaponClass] ) then return end

	local weaponEnt = ply:GetWeapon( weaponClass )

	if( not IsValid( weaponEnt ) ) then return end

	local currentUpgrade = weaponEnt:BRS_GetVariableValue( "BRS_Upgrades" ) or 0
	local maxUpgrades = BRICKS_SERVER.CONFIG.SWEPUPGRADES.BaseUpgradeAmounts or 5
    if( (BRICKS_SERVER.CONFIG.SWEPUPGRADES.UpgradeAmounts or {})[weaponClass] ) then
        maxUpgrades = BRICKS_SERVER.CONFIG.SWEPUPGRADES.UpgradeAmounts[weaponClass]
	end
	
	if( currentUpgrade >= maxUpgrades ) then
		DarkRP.notify( ply, 1, 3, "This weapon is already fully upgraded!" )
		return
	end

	local price = BRICKS_SERVER.CONFIG.SWEPUPGRADES.BasePrice
    for i = 1, currentUpgrade do
        price = math.ceil( price*BRICKS_SERVER.CONFIG.SWEPUPGRADES.PriceIncrease )
    end

	if( ply:getDarkRPVar( "money" ) >= price ) then
		ply:addMoney( -price )

		for k, v in pairs( BRICKS_SERVER.DEVCONFIG.SWEPUpgradeTypes ) do
			if( not BRICKS_SERVER.CONFIG.SWEPUPGRADES.IncreasePercent[k] ) then continue end

			v.SetFunc( weaponEnt, BRICKS_SERVER.CONFIG.SWEPUPGRADES.IncreasePercent[k]/100 )
		end

		weaponEnt:BRS_SetVariable( "BRS_Upgrades", currentUpgrade+1 )

		DarkRP.notify( ply, 1, 3, "This weapon has been upgraded to tier " .. (currentUpgrade+1) .. " for " .. DarkRP.formatMoney( price ) .. "!" )
	else
		DarkRP.notify( ply, 1, 3, "You cannot afford this weapon upgrade!" )
	end
end )

local weaponMeta = FindMetaTable( "Weapon" )

util.AddNetworkString( "BRS.Net.SendSWEPInfo" )
function weaponMeta:BRS_SetVariable( variable, value, plyFallback )
	local owner = self.Owner
	
	if( plyFallback and IsValid( plyFallback ) ) then 
		owner = plyFallback
	end

	if( not IsValid( owner ) ) then return end

	if( self.Primary and self.Primary[variable] ) then
		self.Primary[variable] = value
	else
		self[variable] = value
	end

	net.Start( "BRS.Net.SendSWEPInfo" )
		net.WriteString( self:GetClass() )
		net.WriteString( variable )
		net.WriteFloat( value )
	net.Send( owner )
end

function weaponMeta:BRS_SetWeaponTier( tier, plyFallback )
	for i = 1, tier do
		for k, v in pairs( BRICKS_SERVER.DEVCONFIG.SWEPUpgradeTypes ) do
			if( not BRICKS_SERVER.CONFIG.SWEPUPGRADES.IncreasePercent[k] ) then continue end

			v.SetFunc( self, BRICKS_SERVER.CONFIG.SWEPUPGRADES.IncreasePercent[k]/100 )
		end
	end

	self:BRS_SetVariable( "BRS_Upgrades", tier, plyFallback )
end