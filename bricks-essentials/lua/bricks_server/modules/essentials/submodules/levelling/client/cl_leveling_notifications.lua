NotificationType = false
NotificationAmount = 0
DeleteTimer = 0
local NotificationTime = 1.5

local function AddNotification( levelOrExp, amount )
	local NewNotificationType = levelOrExp and "Level" or "Experience"
	if( not NotificationType ) then
		NotificationType = NewNotificationType
		NotificationAmount = amount
		DeleteTimer = CurTime()+NotificationTime
	elseif( NewNotificationType == NotificationType ) then
		NotificationAmount = NotificationAmount+amount
		DeleteTimer = CurTime()+NotificationTime
	elseif( NewNotificationType == "Level" ) then
		NotificationType = NewNotificationType
		NotificationAmount = amount
		DeleteTimer = CurTime()+NotificationTime
	end
end

local yPos = 60
hook.Add( "HUDPaint", "BRS.HUDPaint_LevellingNotifications", function()
	if( NotificationType ) then
		draw.SimpleText( "+" .. NotificationAmount .. ((NotificationType == "Experience" and " EXP") or " LVL"), "BRICKS_SERVER_HUDFontB", ScrW()/2-1, yPos+1, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( "+" .. NotificationAmount .. ((NotificationType == "Experience" and " EXP") or " LVL"), "BRICKS_SERVER_HUDFontB", ScrW()/2, yPos, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		if( CurTime() >= DeleteTimer ) then
			NotificationType = false
			NotificationAmount = 0
		end
	end
end )

net.Receive( "BRS.Net.LevelNotify", function( len, pl )
	local levelOrExp = net.ReadBool()
	local amount = net.ReadUInt( 32 )
	AddNotification( levelOrExp, amount )
end )